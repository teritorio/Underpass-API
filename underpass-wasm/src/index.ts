import * as duckdb from '@duckdb/duckdb-wasm';
// @ts-expect-error
import duckdb_wasm from '@duckdb/duckdb-wasm/dist/duckdb-mvp.wasm?url';
// @ts-expect-error
import mvp_worker from '@duckdb/duckdb-wasm/dist/duckdb-browser-mvp.worker.js?url';
// @ts-expect-error
import duckdb_wasm_eh from '@duckdb/duckdb-wasm/dist/duckdb-eh.wasm?url';
// @ts-expect-error
import eh_worker from '@duckdb/duckdb-wasm/dist/duckdb-browser-eh.worker.js?url';


import init, * as underpass from '../pkg/underpass.js';

class Connection {
  private connection: duckdb.AsyncDuckDBConnection;
  private status: (log: string) => void;

  constructor(
    connection: duckdb.AsyncDuckDBConnection,
    status: (log: string) => void,
  ) {
    this.connection = connection;
    this.status = status;
  }

  async query(
    overpass: string,
    row_callback: (object: Object) => void
  ) {
    underpass.query(overpass).then(sql => {
      this.status(`Parsing Overpass query\n${overpass}`);

      console.log('Query Result:', sql);

      this.status(`SQL query\n${sql}`);
      const startTimeS = performance.now();
      this.connection.query(sql).then(result => {
        const endTimeS = performance.now();
        this.status(`Execution of SQL query in ${endTimeS - startTimeS}ms`);

        this.status('Fetching results');
        const startTimeR = performance.now();
        let count = 0;
        for (const row of result) {
          row_callback(JSON.parse(row.toArray()[0]));
          count += 1;
        }
        const endTimeR = performance.now();
        this.status(`Fetched ${count} results in ${endTimeR - startTimeR}ms`);
      });
    }).catch(error => {
      console.error('Error executing query:', error);
    });
  }
}

async function getConnection(
  quackosm_parquet: string,
  callback: (connection: Connection) => void,
  status: (log: string) => void,
) {
  const MANUAL_BUNDLES: duckdb.DuckDBBundles = {
    mvp: {
      mainModule: duckdb_wasm,
      mainWorker: mvp_worker,
    },
    eh: {
      mainModule: duckdb_wasm_eh,
      mainWorker: eh_worker,
    },
  };
  // Select a bundle based on browser checks
  const bundle = await duckdb.selectBundle(MANUAL_BUNDLES);
  // Instantiate the asynchronous version of DuckDB-wasm
  const worker = new Worker(bundle.mainWorker!);
  const logger = new duckdb.ConsoleLogger();
  status('DuckDB-wasm loaded');

  const db = new duckdb.AsyncDuckDB(logger, worker);
  await db.instantiate(bundle.mainModule, bundle.pthreadWorker);

  await init();
  status('DuckDB-wasm initialized');

  db.connect().then(async (connection) => {
    const sql = underpass.prepare(quackosm_parquet);
    connection.query(sql).then(_ => {
      status(`DuckDB-wasm configured to ${quackosm_parquet}`);

      callback(new Connection(connection, status));
    });
  });
}

export { getConnection, Connection };

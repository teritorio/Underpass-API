import * as duckdb from '@duckdb/duckdb-wasm';
declare class Connection {
    private connection;
    private status;
    constructor(connection: duckdb.AsyncDuckDBConnection, status: (log: string) => void);
    query(overpass: string): Promise<IterableIterator<Object>>;
}
declare function getConnection(quackosm_parquet: string, status: (log: string) => void): Promise<Connection>;
export { getConnection, Connection };
//# sourceMappingURL=index.d.ts.map
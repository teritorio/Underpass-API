import { getConnection, Connection } from './index.js'

async function query(parquet: string, overpass: string, logger: (status: string) => void): Promise<IterableIterator<Object>> {
  return getConnection(parquet, logger).then((connection: Connection) => {
    return connection.query(overpass);
  });
}

export { query };

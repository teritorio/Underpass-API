import { getConnection, Connection } from './index.js'

function query(parquet: string, overpass: string, log: Node) {
    getConnection(
        parquet,
        (connection: Connection) => {
            connection.query(overpass, (osm_object) => {
                const p = document.createElement('div');
                p.textContent = JSON.stringify(osm_object, null, 2);
                log.appendChild(p);
            });
        },
        (status) => {
            const p = document.createElement('div');
            p.textContent = status;
            log.appendChild(p);
        },
    );
}

export { query };

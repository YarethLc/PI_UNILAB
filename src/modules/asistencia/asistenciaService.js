const pool = require("../../config/db");

const registrarEntrada = async (idUsuario, idLaboratorio) => {
    const consulta = `
        INSERT INTO asistencia (id_usuario, id_laboratorio)
        VALUES ($1, $2)
        RETURNING
            id_asistencia,
            id_usuario,
            id_laboratorio,
            TO_CHAR(fecha, 'YYYY-MM-DD') AS fecha,
            TO_CHAR(hora_entrada, 'YYYY-MM-DD"T"HH24:MI:SS.MS') AS hora_entrada,
            TO_CHAR(hora_salida, 'YYYY-MM-DD"T"HH24:MI:SS.MS') AS hora_salida;
    `;

    const resultado = await pool.query(consulta, [
        idUsuario,
        idLaboratorio
    ]);

    return resultado.rows[0];
};

const registrarSalida = async (idUsuario) => {
    const consulta = `
        UPDATE asistencia
        SET hora_salida = CURRENT_TIMESTAMP
        WHERE id_usuario = $1
            AND hora_salida IS NULL
        RETURNING
                id_asistencia,
                id_usuario,
                id_laboratorio,
                TO_CHAR(fecha, 'YYYY-MM-DD') AS fecha,
                TO_CHAR(hora_entrada, 'YYYY-MM-DD"T"HH24:MI:SS.MS') AS hora_entrada,
                TO_CHAR(hora_salida, 'YYYY-MM-DD"T"HH24:MI:SS.MS') AS hora_salida;
    `;

    const resultado = await pool.query(consulta, [idUsuario]);

    return resultado.rows[0] || null;
};

const obtenerHistorial = async (idUsuario) => {
    const consulta = `

        SELECT
            a.id_asistencia,
            a.id_usuario,
            u.nombres,
            u.apellidos,
            a.id_laboratorio,
            l.nombre AS laboratorio,
            TO_CHAR(a.fecha, 'YYYY-MM-DD') AS fecha,
            TO_CHAR(a.hora_entrada, 'YYYY-MM-DD"T"HH24:MI:SS.MS') AS hora_entrada,
            TO_CHAR(a.hora_salida, 'YYYY-MM-DD"T"HH24:MI:SS.MS') AS hora_salida
        FROM asistencia a
        INNER JOIN usuario u
            ON u.id_usuario = a.id_usuario
        INNER JOIN laboratorio l
            ON l.id_laboratorio = a.id_laboratorio
        WHERE a.id_usuario = $1
        ORDER BY a.hora_entrada DESC`;


    const resultado = await pool.query(consulta, [idUsuario]);

    return resultado.rows;
};

module.exports = {
    registrarEntrada,
    registrarSalida,
    obtenerHistorial
};

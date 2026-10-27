
const pool = require("../config/db");

const estudianteMiddleware = async (req, res, next) => {
    try {
        const idUsuario = req.usuario?.id_usuario;

        if (!idUsuario) {
            return res.status(401).json({
                mensaje: "No se pudo identificar al usuario."
            });
        }

        const resultado = await pool.query(
            `SELECT tipo_usuario
             FROM usuario
             WHERE id_usuario = $1`,
            [idUsuario]
        );

        if (resultado.rowCount === 0) {
            return res.status(401).json({
                mensaje: "El usuario no existe."
            });
        }

        if (resultado.rows[0].tipo_usuario !== "ESTUDIANTE") {
            return res.status(403).json({
                mensaje: "El control de asistencia está disponible únicamente para estudiantes."
            });
        }

        next();
    } catch (error) {
        console.error("Error al validar el tipo de usuario:", error);

        return res.status(500).json({
            mensaje: "No fue posible validar los permisos del usuario."
        });
    }
};

module.exports = estudianteMiddleware;

const express = require("express");
const {
    listarHorarios,
    crearHorario,
    actualizarEstadoHorario
} = require("./horarioController");
const { verificarToken, autorizarRoles } = require("../../middlewares/authMiddleware");

const router = express.Router();

router.get("/", verificarToken, listarHorarios);
router.post("/", verificarToken, autorizarRoles("ADMINISTRADOR"), crearHorario);
router.patch("/:id/estado", verificarToken, autorizarRoles("ADMINISTRADOR"), actualizarEstadoHorario);

module.exports = router;

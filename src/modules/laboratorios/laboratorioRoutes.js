const express = require("express");

const {
    obtenerLaboratorios,
    obtenerLaboratoriosPorId,
    crearLaboratorio,
    eliminarLaboratorio,
    editarLaboratorio
} = require('./laboratorioController');

const router = express.Router();

router.get("/", obtenerLaboratorios);
router.get("/:id", obtenerLaboratoriosPorId);
router.post("/", crearLaboratorio);
router.delete("/:id", eliminarLaboratorio);
router.put("/:id", editarLaboratorio);

module.exports = router;
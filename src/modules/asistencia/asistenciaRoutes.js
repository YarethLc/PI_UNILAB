
const express = require("express");
const router = express.Router();

const asistenciaController = require("./asistenciaController");
const authMiddleware = require("../../middlewares/authMiddleware");
const estudianteMiddleware = require("../../middlewares/estudianteMiddleware");

router.use(authMiddleware);
router.use(estudianteMiddleware);

router.post("/entrada", asistenciaController.registrarEntrada);
router.put("/salida", asistenciaController.registrarSalida);
router.get("/historial", asistenciaController.obtenerHistorial);

module.exports = router;

const express = require('express');

const {
    obtenerHorarios,
    crearHorario,
    actualizarHorario,
    eliminarHorario
} = require('./horarioController');

const router = express.Router();

router.get('/', obtenerHorarios);
router.post('/', crearHorario);
router.put('/:id', actualizarHorario);
router.delete('/:id', eliminarHorario);

module.exports = router;
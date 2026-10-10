const express = require('express');
const router = express.Router();

const reservaController = require('./reservaController');
const authMiddleware = require('../../middlewares/authMiddleware');

router.post('/', authMiddleware, reservaController.crearReserva);
router.get('/', authMiddleware, reservaController.obtenerReservas);
router.get('/:id', authMiddleware, reservaController.obtenerReservaPorId);
router.put('/:id', authMiddleware, reservaController.editarReserva);
router.delete('/:id', authMiddleware, reservaController.cancelarReserva);

module.exports = router;
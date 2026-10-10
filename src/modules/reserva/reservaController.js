const reservaService = require('./reservaService');

const crearReserva = async (req, res) => {

    try {

        const {
            id_laboratorio,
            fecha,
            horaInicio,
            horaFin
        } = req.body;

        const id_usuario = req.usuario.id_usuario;

        if (!id_laboratorio || !fecha || !horaInicio || !horaFin) {
            return res.status(400).json({
                error: 'Todos los campos son obligatorios'
            });
        }

        const reserva = await reservaService.crearReserva({
            id_usuario,
            id_laboratorio,
            fecha,
            horaInicio,
            horaFin
        });

        return res.status(201).json({
            message: 'Reserva creada exitosamente',
            reserva
        });

    } catch (error) {

        console.error("ERROR:", error);

        return res.status(400).json({
            error: error.message
        });
    }
};

//Obtener todas las reservas

const obtenerReservas = async (req, res) => {

    try {

        const reservas = await reservaService.obtenerReservas();

        return res.status(200).json(reservas);

    } catch (error) {

        console.error(error);

        return res.status(500).json({
            error: error.message
        });
    }
};

//Obtener reserva por ID

const obtenerReservaPorId = async (req, res) => {

    try {

        const { id } = req.params;

        const reserva = await reservaService.obtenerReservaPorId(id);

        if (!reserva) {
            return res.status(404).json({
                error: 'Reserva no encontrada'
            });
        }

        res.status(200).json(reserva);
    
    } catch (error) {

        console.error(error);

        return res.status(500).json({
            error: error.message
        });
    }
};

//Editar reserva

const editarReserva = async (req, res) => {

    try {

        const { id } = req.params;

        const {
            id_laboratorio,
            fecha,
            horaInicio,
            horaFin
        } = req.body;

        const id_usuario = req.usuario.id_usuario;
    
        if(!id_laboratorio || !fecha || !horaInicio || !horaFin) {
            return res.status(400).json({
                error: 'Todos los campos son obligatorios'
            });
        }

        const reserva = await reservaService.editarReserva(
            id,
            id_usuario, 
            id_laboratorio,
            fecha,
            horaInicio,
            horaFin
        );

        return res.status(200).json({
            message: 'Reserva editada exitosamente',
            reserva
        });

    } catch (error) {

        console.error(error);

        return res.status(400).json({
            error: error.message
        });
    }
};


//Cancelar reserva

const cancelarReserva = async (req, res) => {

    try {   

        const { id } = req.params;

        const reserva = await reservaService.cancelarReserva(id, req.usuario.id_usuario);

        return res.status(200).json({
            message: 'Reserva cancelada exitosamente',
            reserva
        });
    
    } catch (error) {

        console.error(error);

        return res.status(400).json({
            error: error.message
        });
    }
};


module.exports = {
    crearReserva,
    obtenerReservas,
    obtenerReservaPorId,
    editarReserva,
    cancelarReserva
};
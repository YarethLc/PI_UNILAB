const express = require("express");
const authRoutes = require("./modules/auth/authRoutes");
const app = express();

const reservaRoutes = require("./modules/reserva/reservaRoutes");


app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/reservas", reservaRoutes);

app.get("/", (req, res) => {
    res.json({
        mensaje: "API de reservas funcionando correctamente"
    });
});

const laboratorioRoutes = require("./modules/laboratorios/laboratorioRoutes");
app.use("/api/laboratorios", laboratorioRoutes);

module.exports = app;
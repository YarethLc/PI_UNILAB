require("dotenv").config();
const express = require("express");
const cors = require("cors");
const authRoutes = require("./modules/auth/authRoutes");
const reservaRoutes = require("./modules/reserva/reservaRoutes");
const laboratorioRoutes = require("./modules/laboratorios/laboratorioRoutes");
const horarioRoutes = require("./modules/horarios/horarioRoutes");

const app = express();

app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/reservas", reservaRoutes);
app.use("/api/laboratorios", laboratorioRoutes);
app.use("/api/horarios", horarioRoutes);

app.get("/", (req, res) => {
    res.json({
        mensaje: "API de reservas funcionando correctamente"
    });
});

module.exports = app;
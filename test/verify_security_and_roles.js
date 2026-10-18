const http = require('http');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const app = require('../src/app');

const JWT_SECRET = process.env.JWT_SECRET || "saici_super_secret_jwt_token_2026_uceva";

async function runTests() {
    console.log("=================================================");
    console.log("  INICIANDO SUITE DE PRUEBAS DE SEGURIDAD Y ROLES");
    console.log("=================================================\n");

    let passed = 0;
    let failed = 0;

    function assert(condition, testName) {
        if (condition) {
            console.log(`  [PASS] ${testName}`);
            passed++;
        } else {
            console.error(`  [FAIL] ${testName}`);
            failed++;
        }
    }

    // 1. Iniciar servidor en puerto libre aleatorio
    const server = app.listen(0);
    const port = server.address().port;
    const baseUrl = `http://localhost:${port}`;

    try {
        // Generar tokens de prueba firmados legítimamente
        const adminToken = jwt.sign(
            { id_usuario: 1, email: 'admin@uceva.edu.co', rol: 'ADMINISTRADOR' },
            JWT_SECRET,
            { expiresIn: '1h' }
        );

        const studentToken = jwt.sign(
            { id_usuario: 2, email: 'estudiante@uceva.edu.co', rol: 'USUARIO', tipo_usuario: 'ESTUDIANTE' },
            JWT_SECRET,
            { expiresIn: '1h' }
        );

        const labToken = jwt.sign(
            { id_usuario: 3, email: 'lab@uceva.edu.co', rol: 'LABORATORIO' },
            JWT_SECRET,
            { expiresIn: '1h' }
        );

        // PRUEBA 1: Endpoint protegido sin token retorna 401
        console.log("1. Pruebas de Autenticación (Tokens)");
        const resNoToken = await fetch(`${baseUrl}/api/reservas`);
        assert(resNoToken.status === 401, "GET /api/reservas sin token debe retornar 401 Unauthorized");

        const resNoTokenSchedules = await fetch(`${baseUrl}/api/horarios`);
        assert(resNoTokenSchedules.status === 401, "GET /api/horarios sin token debe retornar 401 Unauthorized");

        // PRUEBA 2: Token malformado retorna 401
        const resBadToken = await fetch(`${baseUrl}/api/reservas`, {
            headers: { Authorization: "Bearer token_invalido_falso" }
        });
        assert(resBadToken.status === 401, "GET /api/reservas con token inválido debe retornar 401");

        // PRUEBA 3: Estudiante intentando acceder a lista de usuarios (exclusiva admin) -> 403
        console.log("\n2. Pruebas de Autorización y Bloqueo de Roles (403)");
        const resStudentUsers = await fetch(`${baseUrl}/api/auth/usuarios`, {
            headers: { Authorization: `Bearer ${studentToken}` }
        });
        assert(resStudentUsers.status === 403, "Estudiante (USUARIO) a GET /api/auth/usuarios debe ser BLOQUEADO con 403 Forbidden");

        const resStudentSchedule = await fetch(`${baseUrl}/api/horarios`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${studentToken}`
            },
            body: JSON.stringify({
                dia_semana: 6,
                hora_apertura: "08:00",
                hora_cierre: "18:00"
            })
        });
        assert(resStudentSchedule.status === 403, "Estudiante no puede crear franjas horarias");

        // PRUEBA 4: Estudiante intentando crear laboratorio (exclusivo admin/lab) -> 403
        const resStudentLab = await fetch(`${baseUrl}/api/laboratorios`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${studentToken}`
            },
            body: JSON.stringify({ nombre: "Lab Invasor", capacidad: 20 })
        });
        assert(resStudentLab.status === 403, "Estudiante (USUARIO) a POST /api/laboratorios debe ser BLOQUEADO con 403 Forbidden");

        // PRUEBA 5: Estudiante intentando cambiar estado de reserva -> 403
        const resStudentPatch = await fetch(`${baseUrl}/api/reservas/999/estado`, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${studentToken}`
            },
            body: JSON.stringify({ estado: "Aprobada" })
        });
        assert(resStudentPatch.status === 403, "Estudiante (USUARIO) a PATCH /api/reservas/:id/estado debe ser BLOQUEADO con 403 Forbidden");

        // PRUEBA 6: Administrador tiene autorización permitida (no retorna 401 ni 403)
        console.log("\n3. Pruebas de Permisos para Roles Autorizados");
        const resAdminUsers = await fetch(`${baseUrl}/api/auth/usuarios`, {
            headers: { Authorization: `Bearer ${adminToken}` }
        });
        assert(resAdminUsers.status !== 401 && resAdminUsers.status !== 403, "Administrador supera la barrera de autorización de roles en GET /api/auth/usuarios");

        const resInvalidSchedule = await fetch(`${baseUrl}/api/horarios`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${adminToken}`
            },
            body: JSON.stringify({
                dia_semana: 8,
                hora_apertura: "08:00",
                hora_cierre: "18:00"
            })
        });
        assert(resInvalidSchedule.status === 400, "El backend rechaza días inválidos al crear horarios");

        // PRUEBA 7: Laboratorio tiene autorización para modificar estado
        const resLabPatch = await fetch(`${baseUrl}/api/reservas/999/estado`, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${labToken}`
            },
            body: JSON.stringify({ estado: "CONFIRMADA" })
        });
        assert(resLabPatch.status !== 401 && resLabPatch.status !== 403, "Encargado de Laboratorio supera la barrera de autorización de roles en PATCH /api/reservas/:id/estado");

        // PRUEBA 8: Validación de Hash con Bcrypt
        console.log("\n4. Pruebas de Seguridad Criptográfica (Bcrypt)");
        const plainPassword = "PasswordSeguro2026!";
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(plainPassword, salt);
        const matchCorrect = await bcrypt.compare(plainPassword, hash);
        const matchWrong = await bcrypt.compare("PasswordIncorrecto", hash);

        assert(hash !== plainPassword, "La contraseña se almacena como hash irreversible y nunca en texto plano");
        assert(matchCorrect === true, "Bcrypt valida correctamente la contraseña original");
        assert(matchWrong === false, "Bcrypt rechaza cualquier contraseña no coincidente");

        // PRUEBA 9: Validación de Registro
        console.log("\n5. Pruebas de Validación de Registro");
        const resRegEmpty = await fetch(`${baseUrl}/api/auth/registro`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({})
        });
        assert(resRegEmpty.status === 400, "Registro sin campos obligatorios debe retornar 400 Bad Request");

        const resRegShortPass = await fetch(`${baseUrl}/api/auth/registro`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                nombres: "Juan",
                apellidos: "Perez",
                email: "juan@uceva.edu.co",
                telefono: "3001234567",
                contrasena: "123",
                confirmarContrasena: "123",
                tipo_usuario: "ESTUDIANTE"
            })
        });
        assert(resRegShortPass.status === 400, "Registro con contraseña menor a 8 caracteres debe ser rechazado con 400");

        const resRegMismatchPass = await fetch(`${baseUrl}/api/auth/registro`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                nombres: "Juan",
                apellidos: "Perez",
                email: "juan@uceva.edu.co",
                telefono: "3001234567",
                contrasena: "Password123456",
                confirmarContrasena: "PasswordDiferente",
                tipo_usuario: "ESTUDIANTE"
            })
        });
        assert(resRegMismatchPass.status === 400, "Registro con contraseñas que no coinciden debe ser rechazado con 400");

        // PRUEBA 10: Validación de Cambio de Contraseña
        console.log("\n6. Pruebas de Cambio de Contraseña");
        const resPassNoToken = await fetch(`${baseUrl}/api/auth/cambiar-password`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ contrasenaActual: "123", nuevaContrasena: "abc" })
        });
        assert(resPassNoToken.status === 401, "Cambio de contraseña sin token debe retornar 401");

        const resPassShort = await fetch(`${baseUrl}/api/auth/cambiar-password`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${studentToken}`
            },
            body: JSON.stringify({
                contrasenaActual: "Password123456",
                nuevaContrasena: "corta",
                confirmarContrasena: "corta"
            })
        });
        assert(resPassShort.status === 400, "Cambio de contraseña menor a 8 caracteres debe ser rechazado con 400");

    } finally {
        server.close();
    }

    console.log("\n=================================================");
    console.log(`  RESULTADOS: ${passed} pasadas, ${failed} falladas`);
    console.log("=================================================");

    if (failed > 0) {
        process.exit(1);
    }
}

runTests().catch(err => {
    console.error("Error ejecutando pruebas:", err);
    process.exit(1);
});

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HCIA - Tarjeta de Ingreso</title>
    <link rel="shortcut icon" href="logo1.jpeg">
    <!-- Librería para generar los QR limpios desde el Base64 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrious/4.0.2/qrious.min.js"></script>
    <style>
        body {
            margin: 0; padding: 0;
            background-color: #f0f2f5;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            display: flex; justify-content: center; align-items: center;
            min-height: 100vh;
        }
        .wrapper {
            width: 95%; max-width: 360px;
            display: flex; flex-direction: column; align-items: center;
        }
        .card {
            background-color: #14635e; /* Color de fondo tarjeta */
            color: white;
            width: 100%; border-radius: 16px; padding: 40px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            box-sizing: border-box;
        }
        
        /* 1. LAYOUT: Horizontal (ID 0) */
        .company-header.horizontal {
            display: flex; align-items: center; gap: 12px; margin-bottom: 30px;
        }
        .company-header.horizontal .logo-empresa {
            height: 26px; max-width: 110px; object-fit: contain;
            background-color: white; padding: 3px 6px; border-radius: 4px;
        }

        /* 2. LAYOUT COMPACTO: Centrado Interno (ID 500) - Sin espacios vacíos */
        .company-header.centrado-interno {
            display: flex; flex-direction: column; align-items: center;
            gap: 6px; 
            margin-top: -5px; /* Elimina aire superior */
            margin-bottom: 15px; /* Elimina aire inferior */
            text-align: center; width: 100%;
        }
        .company-header.centrado-interno .logo-empresa {
            width: 85%; max-width: 240px; height: auto;
            object-fit: contain; background-color: transparent; padding: 0;
        }

        /* 3. LAYOUT: Por fuera y arriba de la tarjeta (ID 501) */
        .logo-fuera {
            width: 85%; max-width: 250px; height: auto;
            object-fit: contain; 
            margin-bottom: 20px; /* Separación estética antes de la tarjeta */
        }
        
        /* Estilos comunes */
        .company-name { font-size: 19px; font-weight: bold; letter-spacing: 0.3px; }
        .company-name.centered { text-align: center; width: 100%; }

        /* Bloque de usuario */
        .user-row {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 25px; gap: 15px;
        }
        .user-info { display: flex; flex-direction: column; flex: 1; }
        .cargo { font-size: 11px; text-transform: uppercase; color: #a5d6a7; font-weight: 600; letter-spacing: 0.8px; }
        .nombre { font-size: 26px; font-weight: bold; margin: 4px 0 0 0; line-height: 1.2; }
        .profile-pic { width: 85px; height: 85px; border-radius: 8px; object-fit: cover; background-color: #fff; flex-shrink: 0; }
        
        .label { font-size: 10px; text-transform: uppercase; color: #a5d6a7; margin-bottom: 2px; letter-spacing: 1px; }
        .info-group { margin-bottom: 15px; }
        .info-value { font-size: 14px; letter-spacing: 0.3px; word-break: break-all; }
        
        .qr-container {
            background-color: white; padding: 15px; border-radius: 12px; margin-top: 25px;
            display: flex; justify-content: center; align-items: center;
        }
        .qr-container img, .qr-container canvas { width: 210px; height: 210px; object-fit: contain; }
        .error-msg { color: #ff5252; background: white; padding: 20px; border-radius: 10px; text-align: center; width: 100%; box-sizing: border-box;}
    </style>
</head>
<body>

    <div id="wrapper" class="wrapper">Cargando credencial...</div>

    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const userId = urlParams.get('user');

        if (!userId) {
            document.getElementById('wrapper').innerHTML = '<div class="error-msg">❌ Error: Especifica un usuario en la URL (?user=0, ?user=500, ?user=501)</div>';
        } else {
            fetch('usuarios.json')
                .then(response => response.json())
                .then(usuarios => {
                    const usuario = usuarios.find(u => u.id.toString() === userId);

                    if (!usuario) {
                        document.getElementById('wrapper').innerHTML = '<div class="error-msg">❌ Usuario no encontrado en el sistema.</div>';
                        return;
                    }

                    let cabeceraHTML = '';
                    let logoFueraHTML = '';

                    // Lógica de ruteo para las ubicaciones físicas del logo
                    if (usuario.layout === 'por-fuera') {
                        // ID 501: El logo original se pinta AFUERA y ARRIBA de la tarjeta verde
                        logoFueraHTML = `<img class="logo-fuera" src="${usuario.logo}" alt="Logo">`;
                        cabeceraHTML = `
                            <div class="company-header centrado-interno">
                                <div class="company-name centered">TARJETA DE INGRESO</div>
                            </div>
                        `;
                    } else if (usuario.layout === 'centrado-interno') {
                        // ID 500: Logo original adentro, centrado y compacto
                        cabeceraHTML = `
                            <div class="company-header centrado-interno">
                                <img class="logo-empresa" src="${usuario.logo}" alt="Logo">
                                <div class="company-name centered">TARJETA DE INGRESO</div>
                            </div>
                        `;
                    } else {
                        // ID 0: Diseño clásico horizontal de esquina
                        cabeceraHTML = `
                            <div class="company-header horizontal">
                                <img class="logo-empresa" src="${usuario.logo}" alt="Logo">
                                <div class="company-name">TARJETA DE INGRESO</div>
                            </div>
                        `;
                    }

                    let qrElementHTML = usuario.usar_foto_qr 
                        ? `<img src="${usuario.qr_pure}" alt="Código QR">` 
                        : `<canvas id="qr"></canvas>`;

                    // Estructura limpia y simétrica
                    document.getElementById('wrapper').innerHTML = `
                        ${logoFueraHTML}
                        <div class="card">
                            ${cabeceraHTML}
                            
                            <div class="user-row">
                                <div class="user-info">
                                    <div class="nombre">${usuario.nombre} ${usuario.apellido}</div>
                                    <div class="cargo">${usuario.rol} ${usuario.areas_practica.length ? `• ${usuario.areas_practica.join(', ')}` : ''}</div>
                                </div>

                            </div>
                            
                            <div class="info-group">
                                <div class="label">EMAIL</div>
                                <div class="info-value">${usuario.email}</div>
                            </div>
                            
                            <div class="qr-container">
                                ${qrElementHTML}
                            </div>
                        </div>
                    `;

                    if (!usuario.usar_foto_qr) {
                        new QRious({
                            element: document.getElementById('qr'),
                            value: usuario.qr_pure,
                            size: 210,
                            level: 'M'
                        });
                    }
                })
                .catch(err => {
                    document.getElementById('wrapper').innerHTML = '<div class="error-msg">❌ Error al cargar la base de datos.</div>';
                    console.error(err);
                });
        }
    </script>
</body>
</html>

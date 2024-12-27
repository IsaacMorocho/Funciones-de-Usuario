-- Tabla Clientes
CREATE TABLE Clientes (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    apellido TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    telefono TEXT,
    fecha_registro DATETIME
);
--Tabla Productos
CREATE TABLE Productos (
    id INTEGER PRIMARY KEY ,
    nombre TEXT NOT NULL UNIQUE,
    precio REAL NOT NULL CHECK (precio > 0),
    stock INTEGER NOT NULL CHECK (stock >= 0),
    descripcion TEXT
);
-- Tabla Pedidos
CREATE TABLE Pedidos (
    id INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    fecha_pedido DATETIME,
    total REAL NOT NULL CHECK (total >= 0),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id)
);

-- Tabla Detalles_Pedido
CREATE TABLE Detalles_Pedido (
    id INTEGER PRIMARY KEY,
    pedido_id INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario REAL NOT NULL CHECK (precio_unitario > 0),
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES Productos(id)
);

INSERT INTO Clientes (id,nombre, apellido, email, telefono) 
VALUES
(001,'Alexander', 'Pérez', 'juan.perez@gmail.com', '093456789'),
(002,'Josias', 'Gómez', 'maria.gomez@gmail.com', '097654321'),
(003,'Carlos', 'Zambrano', 'carlos.lopez@gmail.com', '0956789123'),
(004,'Leticis', 'Martínez', 'ana.martinez@gmail.com', '0921654987'),
(005,'Florinda', 'Fernández', 'luis.fernandez@gmail.com', '0954321789');

INSERT INTO Productos (id,nombre, precio, stock, descripcion) 
VALUES
(11,'Laptop', 800.00, 10, 'Laptop de 16GB de RAM'),
(12,'Smartphone', 500.00, 20, 'Smartphone pantalla de 6.5 pulgadas'),
(13,'Tablet', 300.00, 15, 'Tablet 64GB de almacenamiento'),
(14,'Auriculares', 100.00, 50, 'Auriculares inalámbricos'),
(15,'Reloj inteligente', 250.00, 30, 'Reloj con monitor de salud');

INSERT INTO Pedidos (id, cliente_id, total) 
VALUES
(1,001, 800.00),
(2,002, 500.00), 
(3,003, 300.00),  
(4,004, 100.00), 
(5,005, 250.00);  

INSERT INTO Detalles_Pedido (pedido_id, producto_id, cantidad, precio_unitario) 
VALUES
(1, 11, 1, 800.00), 
(2, 12, 1, 500.00), 
(3, 13, 1, 300.00),  
(4, 14, 1, 100.00),  
(5, 15, 1, 250.00); 
-- Funciones
-- Función para obtener el nombre completo de un cliente:
SELECT nombre || ' ' || apellido AS nombreCompleto FROM Clientes
WHERE id = 002;  
-- Función para calcular el descuento de un producto:
SELECT precio * (1 - 0.15) AS precio_con_descuento FROM Productos
WHERE id =12;

-- Función para calcular el total de un pedido
SELECT SUM(dp.cantidad * dp.precio_unitario) AS total FROM Detalles_Pedido dp
JOIN Pedidos p ON dp.pedido_id = p.id WHERE p.id = 2;

-- Función para verificar la disponibilidad de stock de un producto:
SELECT CASE 
           WHEN stock >= 0 THEN 'TRUE' 
           ELSE 'FALSE' 
       END AS disponibilidad_Stock_Producto
FROM Productos WHERE id = 13; 

-- Función para calcular la antigüedad de un cliente
SELECT (julianday('now') - julianday(fechaRegistro)) / 365 AS antiguedad
FROM Clientes WHERE id=003;


-- Parte 2
-- 1
CREATE FUNCTION CalcularTotalOrden(id_orden INT)
RETURNS DECIMAL(16,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(16,2);
    DECLARE iva DECIMAL(16,2);

    SET iva = 0.15;

    SELECT SUM(P.precio * O.cantidad) INTO total
    FROM Ordenes O
    JOIN Productos P ON O.producto_id = P.ProductoID
    WHERE O.OrdenID = id_orden;

    SET total = total + (total * iva);

    RETURN total;
END $$

DELIMITER ;

-- 2
DELIMITER $$

CREATE FUNCTION CalcularEdad(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE edad INT;
    SET edad = TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
    RETURN edad;
END $$

DELIMITER ;

-- 3
DELIMITER $$

CREATE FUNCTION VerificarStock(producto_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE stock INT;
    SELECT Existencia INTO stock
    FROM Productos
    WHERE ProductoID = producto_id;
    IF stock > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END $$
DELIMITER ;

-- 4
DELIMITER $$
CREATE FUNCTION CalcularSaldo(id_cuenta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE saldo DECIMAL(10,2);

    SELECT SUM(CASE
        WHEN tipo_transaccion = 'deposito' THEN monto
        WHEN tipo_transaccion = 'retiro' THEN -monto
        ELSE 0
    END) INTO saldo
    FROM Transacciones
    WHERE cuenta_id = id_cuenta;

    RETURN saldo;
END $$
DELIMITER ;

CREATE DATABASE splendor;
USE splendor;

CREATE TABLE Partida
(
  IdPartida SMALLINT UNSIGNED NOT NULL,
  Fecha DATETIME NOT NULL,
  Tiempo SMALLINT UNSIGNED NOT NULL,
  NumeroSala TINYINT UNSIGNED NOT NULL,
  Puntuacion TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (IdPartida)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE Jugador
(
  IdJugador SMALLINT UNSIGNED NOT NULL,
  Nombre VARCHAR(35) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  Constrasenya VARCHAR(15) NOT NULL,
  Rango INT NOT NULL,
  PRIMARY KEY (IdJugador),
  UNIQUE (Email)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE Color
(
  IdColor ENUM('Red',  'Blue', 'Green', 'White', 'Black', 'Gold') NOT NULL,
  img MEDIUMBLOB,
  PRIMARY KEY (IdColor)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE Carta
(
  IdCarta VARCHAR(20) NOT NULL,
  Puntos TINYINT UNSIGNED NOT NULL,
  Nivel ENUM('1', '2', '3') NOT NULL,
  img MEDIUMBLOB,
  IdColor ENUM('Red',  'Blue', 'Green', 'White', 'Black', 'Gold') NOT NULL,
  PRIMARY KEY (IdCarta),
  FOREIGN KEY (IdColor) REFERENCES Color(IdColor)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE Noble
(
  IdNoble TINYINT UNSIGNED NOT NULL,
  img MEDIUMBLOB,
  PRIMARY KEY (IdNoble)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE CosteNobles
(
  Coste TINYINT UNSIGNED NOT NULL,
  IdColor ENUM('Red',  'Blue', 'Green', 'White', 'Black', 'Gold') NOT NULL,
  IdNoble TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (IdColor, IdNoble),
  FOREIGN KEY (IdColor) REFERENCES Color(IdColor),
  FOREIGN KEY (IdNoble) REFERENCES Noble(IdNoble)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE CosteCarta
(
  Coste TINYINT UNSIGNED NOT NULL,
  IdColor ENUM('Red',  'Blue', 'Green', 'White', 'Black') NOT NULL,
  IdCarta VARCHAR(20) NOT NULL,
  PRIMARY KEY (IdColor, IdCarta),
  FOREIGN KEY (IdColor) REFERENCES Color(IdColor),
  FOREIGN KEY (IdCarta) REFERENCES Carta(IdCarta)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE JugadorPartida
(
  Orden TINYINT UNSIGNED NOT NULL,
  IdPartida SMALLINT UNSIGNED NOT NULL,
  IdJugador SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (IdPartida, IdJugador),
  FOREIGN KEY (IdPartida) REFERENCES Partida(IdPartida),
  FOREIGN KEY (IdJugador) REFERENCES Jugador(IdJugador)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE Accion
(
  Turno TINYINT UNSIGNED NOT NULL,
  Tipo ENUM('take2G', 'take3G', 'buy', 'hold', 'buyHolded', 'pass') NOT NULL,
  IdPartida SMALLINT UNSIGNED NOT NULL,
  IdJugador SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (Turno, IdPartida, IdJugador),
  FOREIGN KEY (IdPartida, IdJugador) REFERENCES JugadorPartida(IdPartida, IdJugador)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE NoblePartida
(
  IdPartida SMALLINT UNSIGNED NOT NULL,
  IdNoble TINYINT UNSIGNED NOT NULL,
  Turno TINYINT UNSIGNED,
  IdPartidaAccion SMALLINT UNSIGNED,
  IdJugador SMALLINT UNSIGNED,
  PRIMARY KEY (IdPartida, IdNoble),
  FOREIGN KEY (IdPartida) REFERENCES Partida(IdPartida),
  FOREIGN KEY (IdNoble) REFERENCES Noble(IdNoble),
  FOREIGN KEY (Turno, IdPartidaAccion, IdJugador) REFERENCES Accion(Turno, IdPartida, IdJugador)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE GemaAccion
(
  Total TINYINT UNSIGNED NOT NULL,
  Variacion TINYINT NOT NULL,
  Turno TINYINT UNSIGNED NOT NULL,
  IdPartida SMALLINT UNSIGNED NOT NULL,
  IdJugador SMALLINT UNSIGNED NOT NULL,
  IdColor ENUM('Red',  'Blue', 'Green', 'White', 'Black', 'Gold') NOT NULL,
  PRIMARY KEY (Turno, IdPartida, IdJugador, IdColor),
  FOREIGN KEY (Turno, IdPartida, IdJugador) REFERENCES Accion(Turno, IdPartida, IdJugador),
  FOREIGN KEY (IdColor) REFERENCES Color(IdColor)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE CartaTablero
(
  IdCarta VARCHAR(20) NOT NULL,
  Turno TINYINT UNSIGNED NOT NULL,
  IdPartida SMALLINT UNSIGNED NOT NULL,
  IdJugador SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (IdCarta, Turno, IdPartida, IdJugador),
  FOREIGN KEY (IdCarta) REFERENCES Carta(IdCarta),
  FOREIGN KEY (Turno, IdPartida, IdJugador) REFERENCES Accion(Turno, IdPartida, IdJugador)
) Engine = InnoDb Default CHARSET= latin1;

CREATE TABLE CartaJugador
(
  Reservada BOOLEAN NOT NULL,
  Turno TINYINT UNSIGNED NOT NULL,
  IdPartida SMALLINT UNSIGNED NOT NULL,
  IdJugador SMALLINT UNSIGNED NOT NULL,
  IdCarta VARCHAR(20) NOT NULL,
  PRIMARY KEY (Turno, IdPartida, IdJugador, IdCarta),
  FOREIGN KEY (Turno, IdPartida, IdJugador) REFERENCES Accion(Turno, IdPartida, IdJugador),
  FOREIGN KEY (IdCarta) REFERENCES Carta(IdCarta)
) Engine = InnoDb Default CHARSET= latin1;
/*Funcion para saber cuantos jugadores hay en una partida */
*CREATE FUNCTION GetNumJugPrt( _idpartida SMALLINT UNSIGNED) RETURNS SMALLINT UNSIGNED

/*Saber el coste del color de una carta */
*CREATE FUNCTION GetCostCartCol(_idcarta VARCHAR(20), _idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black')) RETURNS TINYINT UNSIGNED

/*Saber cuantas cartas tiene un jugador de un color en una accion */
*CREATE FUNCTION GetNumCartesColAcc(_idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black'), _idpartida SMALLINT UNSIGNED, _idjugador SMALLINT UNSIGNED, _turno TINYINT UNSIGNED) 

/* Saber cuantas gemas de un color tiene un jugador en una accion*/
*CREATE FUNCTION GetNumGemColAcc(_idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black', 'Gold'), _idpartida SMALLINT UNSIGNED, _idjugador SMALLINT UNSIGNED, _turno TINYINT UNSIGNED)

/* Saber cuantas gemas tiene en total un jugador*/
*CREATE FUNCTION GetNumGemaAcc(_idpartida SMALLINT UNSIGNED, _idjugador SMALLINT UNSIGNED, _turno TINYINT UNSIGNED) 

/*Saber cuantes gemes hi ha a la partida*/
*CREATE FUNCTION GetNumGemesClrENJoc(_prtId SMALLINT UNSIGNED, _idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black')) RETURNS TINYINT UNSIGNED

/* Saber el poder que tiene un jugador de un color en una accion*/
*CREATE FUNCTION GetPowerColAcc(_idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black'), _idpartida SMALLINT UNSIGNED, _idjugador SMALLINT UNSIGNED, _turno TINYINT UNSIGNED)

/*Crear una partida*/
*CREATE PROCEDURE CrearPrt(_prtId SMALLINT UNSIGNED, _numSala TINYINT UNSIGNED, _objectiu TINYINT UNSIGNED, _tiempo SMALLINT UNSIGNED, _jugId1 SMALLINT UNSIGNED, _jugId2 SMALLINT UNSIGNED, _jugId3 SMALLINT UNSIGNED,_jugId4 SMALLINT UNSIGNED )

/* Procediment per obtenir l'acció següent a una acció dins la partida */
*CREATE PROCEDURE GetAccioSeguent(
IN _prtId SMALLINT UNSIGNED,
IN _jugIdAct SMALLINT UNSIGNED,
IN _tornAct TINYINT UNSIGNED,
OUT _jugIdSeg SMALLINT UNSIGNED,
OUT _tornSeg TINYINT UNSIGNED )

/* Procediment per obtenir l'acció prèvia a una acció dins la partida */
*CREATE PROCEDURE GetAccioAnterior(
IN _prtId SMALLINT UNSIGNED,
IN _jugIdAct SMALLINT UNSIGNED,
IN _tornAct TINYINT UNSIGNED,
OUT _jugIdAnt SMALLINT UNSIGNED,
OUT _tornAnt TINYINT UNSIGNED )

/* Procediment per obtenir la darrera acció enregistrada dins una partida */
*CREATE PROCEDURE GetDarreraAccioPrt(
IN _prtId SMALLINT UNSIGNED,
OUT _jugIdLast SMALLINT UNSIGNED,
OUT _tornLast SMALLINT UNSIGNED )

/* Funció per obtenir la puntuació total d'un jugador en una partida */
*CREATE FUNCTION GetPuntJgdrAcc(
_prtId SMALLINT UNSIGNED,
_jugId SMALLINT UNSIGNED,
_turno TINYINT UNSIGNED
)

/* Procediment per enregistrar una acció "pass" */
*CREATE PROCEDURE NovaAccPass( _prtId INT UNSIGNED )

/*Crear una accio de agafar 2 gemes*/
*CREATE PROCEDURE NovaAccTake2G(_prtId INT UNSIGNED, _color ENUM('Red',  'Blue', 'Green', 'White', 'Black'))

/*Crear una accio de agafar 3 gemes*/
*CREATE PROCEDURE NovaAccTake3G(_prtId INT UNSIGNED, _color1 ENUM('Red',  'Blue', 'Green', 'White', 'Black'), _color2 ENUM('Red',  'Blue', 'Green', 'White', 'Black'), 
_color3 ENUM('Red',  'Blue', 'Green', 'White', 'Black'))


/*Eliminar todas las tablas*/
*CREATE PROCEDURE DeleteTotesPrt()

/*Saber la cantidad de gemas de un color que hay en el tablero*/
CREATE FUNCTION GemasDisponiblesTablero(_prtId INT UNSIGNED, _color ENUM('Red',  'Blue', 'Green', 'White', 'Black','Gold'))

/*Sacar una carta de un nivel que este en el mazo*/
CREATE FUNCTION GetCrtNivell(_prtId INT UNSIGNED, _nivell TINYINT UNSIGNED) RETURNS VARCHAR(20)

CREATE PROCEDURE CartaComprableAcc(
    _prtId INT UNSIGNED,
    _idcarta VARCHAR(20),
    OUT _comprable BOOLEAN,
    OUT _TM ENUM ('T', 'MR')
)

*CREATE PROCEDURE NovaAccBuy(_prtId SMALLINT UNSIGNED, _idcarta VARCHAR(20))

*CREATE PROCEDURE CartaComprableAcc(
    _prtId INT UNSIGNED,
    _idcarta VARCHAR(20),
    OUT _comprable BOOLEAN,
    OUT _TM ENUM ('T', 'MR')
)


*CREATE FUNCTION GetCrtNivell(_prtId INT UNSIGNED, _nivell TINYINT UNSIGNED) RETURNS VARCHAR(20)

*CREATE FUNCTION GemasDisponiblesTablero(_prtId INT UNSIGNED, _color ENUM('Red',  'Blue', 'Green', 'White', 'Black','Gold'))

*CREATE PROCEDURE NovaAccBlindHold(_prtId SMALLINT UNSIGNED, _nivel ENUM('1','2','3'))

*CREATE PROCEDURE NovaAccHold(_prtId SMALLINT UNSIGNED, _idcarta VARCHAR(20))

*CREATE PROCEDURE GetNoble(_prtId SMALLINT UNSIGNED, _idJugador SMALLINT UNSIGNED, _torn TINYINT UNSIGNED)

CREATE FUNCTION SonDiferentes(_color1 ENUM('Red',  'Blue', 'Green', 'White', 'Black'), _color2 ENUM('Red',  'Blue', 'Green', 'White', 'Black'), 
_color3 ENUM('Red',  'Blue', 'Green', 'White', 'Black')) RETURNS TINYINT UNSIGNED
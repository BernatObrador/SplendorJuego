DELIMITER $$

DROP FUNCTION GetNumJugPrt$$

CREATE FUNCTION GetNumJugPrt( _idpartida SMALLINT UNSIGNED) RETURNS SMALLINT UNSIGNED
BEGIN
    DECLARE num SMALLINT UNSIGNED;

    SELECT count(*) INTO num
    FROM JugadorPartida
    WHERE idpartida = _idpartida;
    
    RETURN num ;
END$$

DELIMITER ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


DELIMITER $$

DROP FUNCTION GetCostCartCol$$

CREATE FUNCTION GetCostCartCol(_idcarta VARCHAR(20), _idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black')) RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE num TINYINT UNSIGNED DEFAULT NULL;

    SELECT coste INTO num
    from CosteCarta
    WHERE IdCarta = _idcarta && IdColor = _idcolor;

    RETURN IFNULL(num, 0);
END$$

DELIMITER ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP FUNCTION GetNumCartesColAcc$$

CREATE FUNCTION GetNumCartesColAcc(_idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black'), _idpartida SMALLINT UNSIGNED, _idjugador SMALLINT UNSIGNED, _turno TINYINT UNSIGNED) 
RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE num TINYINT UNSIGNED DEFAULT 0;

    select count(*) INTO num
    from CartaJugador as cj
    inner join carta as c
    on c.IdCarta = cj.IdCarta
    WHERE c.IdColor = _idcolor && cj.idpartida = _idpartida && cj.IdJugador = _idjugador && cj.Turno = _turno && cj.Reservada <> 1;

    RETURN num;
END$$

DELIMITER ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP FUNCTION GetNumGemColAcc$$

CREATE FUNCTION GetNumGemColAcc(_idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black', 'Gold'), _idpartida SMALLINT UNSIGNED, _idjugador SMALLINT UNSIGNED, _turno TINYINT UNSIGNED)
RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE num TINYINT UNSIGNED DEFAULT 0;

    select total into num
    from GemaAccion
    where IdColor = _idcolor && idpartida = _idpartida && IdJugador = _idjugador && Turno = _turno;

    RETURN num;
END$$

DELIMITER ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP FUNCTION GetNumGemaAcc$$

CREATE FUNCTION GetNumGemaAcc(_idpartida SMALLINT UNSIGNED, _idjugador SMALLINT UNSIGNED, _turno TINYINT UNSIGNED) 
RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE num TINYINT UNSIGNED DEFAULT 0;

    select SUM(Total) into num
    from GemaAccion
    where idpartida = _idpartida && IdJugador = _idjugador && Turno = _turno;

    RETURN num;
END$$

DELIMITER ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP FUNCTION GetPowerColAcc$$

CREATE FUNCTION GetPowerColAcc(_idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black'), _idpartida SMALLINT UNSIGNED, _idjugador SMALLINT UNSIGNED, _turno TINYINT UNSIGNED)
RETURNS TINYINT UNSIGNED
BEGIN

    DECLARE num TINYINT UNSIGNED DEFAULT 0;
    DECLARE num1 TINYINT UNSIGNED DEFAULT 0;

    select GetNumCartesColAcc(_idcolor, _idpartida, _idjugador, _turno) into num;
    select GetNumGemColAcc(_idcolor, _idpartida, _idjugador, _turno) into num1;

RETURN num + num1;
END$$

DELIMITER ;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE crearprt;

DELIMITER $$
/* Procediment de creació i configuració completa d'un partida
Mínim 2 jugadors, els jugadors 3 i 4 són opcionals (NULL) */
CREATE PROCEDURE CrearPrt(
_prtId SMALLINT UNSIGNED,
_numSala TINYINT UNSIGNED,
_objectiu TINYINT UNSIGNED,
_tiempo SMALLINT UNSIGNED,
_jugId1 SMALLINT UNSIGNED,
_jugId2 SMALLINT UNSIGNED,
_jugId3 SMALLINT,
_jugId4 SMALLINT )

BEGIN

DECLARE numJugadors TINYINT DEFAULT 2;
DECLARE contador TINYINT; /* Contador per processar el cursor */
DECLARE unIdCrt VARCHAR(20); /* Variable per guardar un id de Carta */
DECLARE unIdNbl TINYINT UNSIGNED; /* Variable per guardar un id de Noble */
DECLARE darrerJug SMALLINT UNSIGNED;
DECLARE cCrt1 CURSOR FOR
    SELECT IdCarta FROM Carta
    WHERE Nivel = '1'
    ORDER BY RAND()
    LIMIT 4;

DECLARE cCrt2 CURSOR FOR
    SELECT IdCarta FROM Carta
        WHERE Nivel = '2'
        ORDER BY RAND()
        LIMIT 4;

DECLARE cCrt3 CURSOR FOR
    SELECT IdCarta FROM Carta
        WHERE Nivel = '3'
        ORDER BY RAND()
        LIMIT 4;

DECLARE cNbl CURSOR FOR
    SELECT IdNoble FROM Noble
        ORDER BY RAND();


START TRANSACTION; /* Obrim transacció per fer tot d'un cop */

/* Cream la partida */
INSERT INTO Partida (IdPartida, NumeroSala, Puntuacion, Fecha, Tiempo)
    VALUES (_prtId, _numSala, _objectiu, SYSDATE(), _tiempo);

/* Associam els jugadors a la partida */
INSERT INTO JugadorPartida (IdPartida, IdJugador, Orden)
    VALUES (_prtId, _jugId1, 1), (_prtId, _jugId2, 2);

SET darrerJug = _jugId2;

IF _jugId3 > -1 THEN
    INSERT INTO JugadorPartida (IdPartida, IdJugador, Orden)
        VALUES (_prtId, _jugId3, 3);
    SET numJugadors = 3;  
    SET darrerJug = _jugId3;

    IF _jugId4 > -1 THEN
        INSERT INTO JugadorPartida (IdPartida, IdJugador, Orden)
            VALUES (_prtId, _jugId4, 4);
        SET numJugadors = 4;
        SET darrerJug = _jugId4;
    END IF;
END IF;

/* Cream una Accio 0 per cada jugador*/
INSERT INTO Accion (IdPartida, IdJugador, Turno, Tipo)
    select _prtId, jp.IdJugador, 0, "pass" from JugadorPartida as jp
    where idpartida = _prtId;


/* Posam 12 cartes sobre la taula */

OPEN cCrt1;
SET contador = 0;
WHILE contador < 4 DO      /* Bucle de procés del cursor */
    FETCH cCrt1 INTO unIdCrt;   /* Llegim un id de Carta del cursor */
    SET contador = contador + 1;
    /* Per cada id de carta llegit, la posam al  */
    INSERT INTO CartaTablero (IdPartida, IdJugador, Turno, IdCarta)
        VALUES(_prtId, darrerJug, 0, unIdCrt); 
END WHILE;
CLOSE cCrt1;


OPEN cCrt2;
SET contador = 0;
WHILE contador < 4 DO      /* Bucle de procés del cursor */
    FETCH cCrt2 INTO unIdCrt;   /* Llegim un id de Carta del cursor */
    SET contador = contador + 1;
    /* Per cada id de carta llegit, la posam al tauler */
    INSERT INTO CartaTablero (IdPartida, IdJugador, Turno, IdCarta)
        VALUES(_prtId, darrerJug, 0, unIdCrt); 
END WHILE;
CLOSE cCrt2;


OPEN cCrt3;
SET contador = 0;
WHILE contador < 4 DO      /* Bucle de procés del cursor */
    FETCH cCrt3 INTO unIdCrt;   /* Llegim un id de Carta del cursor */
    SET contador = contador + 1;
    /* Per cada id de carta llegit, la posam al tauler */
    INSERT INTO CartaTablero (IdPartida, IdJugador, Turno, IdCarta)
        VALUES(_prtId, darrerJug, 0, unIdCrt); 
END WHILE;
CLOSE cCrt3;

/* Posam tants nobles sobre la taula com numJugadors+1 */
OPEN cNbl;
WHILE numJugadors >= 0 DO       /* Bucle de procés del cursor */
    FETCH cNbl INTO unIdNbl;   /* Llegim un id de noble del cursor */
    SET numJugadors = numJugadors - 1;
    INSERT INTO NoblePartida (IdPartida, IdNoble)
        VALUES(_prtId, unIdNbl); 
END WHILE;
CLOSE cNbl;

/*Ponemos gemas a 0 de todos los colores para todos los jugadores*/
    INSERT INTO GemaAccion (total, variacion, turno, idpartida, idjugador, IdColor)
    select 0, 0, 0, _prtId, jp.idjugador, c.IdColor from JugadorPartida as jp, color as c
    where jp.idpartida = _prtId;
    

 COMMIT; /* Confirmam transacció ara ja es veuen tots els canvis */
END$$

DELIMITER ;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetAccioAnterior;
DELIMITER $$

/* Procediment per obtenir l'acció prèvia a una acció dins la partida */
CREATE PROCEDURE GetAccioAnterior(
IN _prtId SMALLINT UNSIGNED,
IN _jugIdAct SMALLINT UNSIGNED,
IN _tornAct TINYINT UNSIGNED,
OUT _jugIdAnt SMALLINT UNSIGNED,
OUT _tornAnt TINYINT UNSIGNED )
BEGIN
DECLARE numJugPrt TINYINT UNSIGNED;
DECLARE ordreJugAct TINYINT;
DECLARE ordreJugAnt TINYINT;

/* Averiguam l'ordre del jugador que ens han passat dins cada torn */
SELECT Orden INTO ordreJugAct
    FROM JugadorPartida
    WHERE IdPartida = _prtId and IdJugador = _jugIdAct;

/* Necessitam saber el número de jugadors */
SELECT GetNumJugPrt(_prtId) INTO numJugPrt;

/* Per averiguar el torn i l'ordre del jugador anterior... */
IF _tornAct = 0 AND ordreJugAct = 1 THEN 
/* L'acció anterior a la de torn 0 sempre és ella mateixa: Torn 0, jugador 1er */
   SET _tornAnt  = 0;
   SET ordreJugAnt = 1;
ELSE

    IF ordreJugAct = 1 THEN
    /* Si el jugador de l'acció és el primer,
    l'acció anterior és la del torn -1... */
        SET _tornAnt = _tornAct -1;
        /* L'acció anterior a jugador 1er, torn X és jugador darrer torn X-1 */
        SET ordreJugAnt = numJugPrt;
        /*END IF;*/
    ELSE
    /* Si el jugador de l'acció no és el primer, l'acció anterior
    és la del jugador que té un ordre-1 dins el mateix torn */
        SET ordreJugAnt = ordreJugAct - 1;
        SET _tornAnt = _tornAct;
    END IF;
    
END IF;


/* Averiguam l'id del jugador anterior */
SELECT IdJugador INTO _jugIdAnt
    FROM JugadorPartida
    WHERE IdPartida = _prtId and Orden = ordreJugAnt;
END$$

DELIMITER ;

----------------------------------------------------------------

DELIMITER $$

DROP FUNCTION GetNumGemesClrENJoc$$

/*Saber cuantes gemes hi ha a la partida*/
CREATE FUNCTION GetNumGemesClrENJoc(_prtId SMALLINT UNSIGNED, _idcolor ENUM('Red',  'Blue', 'Green', 'White', 'Black', 'Gold')) RETURNS TINYINT UNSIGNED

BEGIN

    DECLARE numJug TINYINT UNSIGNED;
    SET numJug = GetNumJugPrt(_prtId);

    IF _idcolor = 'Gold' THEN
        RETURN 5;
END IF;

    IF numJug = 4 THEN
        RETURN 7;
    ELSE
        RETURN numJug + 2;
END IF;

END$$

DELIMITER ;

-----------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS GetAccioSeguent;
DELIMITER $$

/* Procediment per obtenir l'acció següent a una acció dins la partida */

CREATE PROCEDURE GetAccioSeguent(
IN _prtId SMALLINT UNSIGNED,
IN _jugIdAct SMALLINT UNSIGNED,
IN _tornAct TINYINT UNSIGNED,
OUT _jugIdSeg SMALLINT UNSIGNED,
OUT _tornSeg TINYINT UNSIGNED )
BEGIN
DECLARE numJugPrt TINYINT UNSIGNED;
DECLARE ordreJugAct TINYINT UNSIGNED;
DECLARE ordreJugSeg TINYINT UNSIGNED;


/* Averiguam l'ordre del jugador que ens han passat dins cada torn */
SELECT Orden INTO ordreJugAct
    FROM JugadorPartida
    WHERE IdPartida = _prtId AND IdJugador = _jugIdAct;

/* Necessitam saber el número de jugadors */
SELECT GetNumJugPrt(_prtId) INTO numJugPrt;

/* Per averiguar el torn i l'ordre del jugador anterior... */

    IF ordreJugAct = numJugPrt THEN
    /* Si l'acció és del darrer jugador de la roda, l'accio següent és:
    primer jugador, torn +1 */
        SET ordreJugSeg = 1;
        SET _tornSeg = _tornAct +1;
    ELSE
    /* Si l'acció no és del jugador al lloc X de la roda, l'acció següent és:
    jugador del lloc X+1 i mateix torn */
        SET ordreJugSeg = ordreJugAct +1;
        SET _tornSeg = _tornAct;
    END IF;
/* Averiguam l'id del jugador següent */
SELECT IdJugador INTO _jugIdSeg
    FROM JugadorPartida
    WHERE IdPartida = _prtId AND Orden = ordreJugSeg;

END$$

DELIMITER ;



-----------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS GetDarreraAccioPrt;

DELIMITER $$

/* Procediment per obtenir la darrera acció enregistrada dins una partida */
CREATE PROCEDURE GetDarreraAccioPrt(
IN _prtId SMALLINT UNSIGNED,
OUT _jugIdLast SMALLINT UNSIGNED,
OUT _tornLast SMALLINT UNSIGNED )
BEGIN
    
    SELECT a.IdJugador, a.Turno INTO _jugIdLast, _tornLast
    FROM Accion as a
    INNER JOIN JugadorPartida as jp
    ON a.IdJugador = jp.IdJugador AND a.IdPartida = jp.IdPartida
    WHERE a.IdPartida = _prtId
    ORDER BY a.Turno DESC, jp.Orden DESC
    LIMIT 1;

END$$

DELIMITER ;


---------------------------------------------------------------------------------------------------

DROP FUNCTION GetPuntJgdrAcc;
DELIMITER $$

/* Funció per obtenir la puntuació total d'un jugador en una partida */
CREATE FUNCTION GetPuntJgdrAcc(
_prtId SMALLINT UNSIGNED,
_jugId SMALLINT UNSIGNED,
_turno TINYINT UNSIGNED
)
RETURNS TINYINT UNSIGNED

BEGIN
    DECLARE puntuacioCartes TINYINT UNSIGNED;
    DECLARE puntuacioNobles TINYINT UNSIGNED;

/* Obtenir la puntuació total de les cartes del jugador */
    SELECT SUM(c.Puntos) INTO puntuacioCartes
    FROM CartaJugador as cj
    inner join
    Carta as c on c.idcarta = cj.idcarta
    WHERE cj.IdPartida = _prtId AND cj.IdJugador = _jugId AND cj.Turno = _turno AND cj.reservada = 0;

/* Obtenir la puntuació total dels nobles adquirits pel jugador */
    SELECT 3 * count(*) INTO puntuacioNobles
    FROM NoblePartida
    WHERE IdPartida = _prtId AND IdJugador = _jugId;

    RETURN IFNULL (puntuacioCartes, 0) + IFNULL (puntuacioNobles, 0);

END$$

DELIMITER ;


-------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS NovaAccPass$$

/* Procediment per enregistrar una acció "pass" */
CREATE PROCEDURE NovaAccPass( _prtId INT UNSIGNED )
BEGIN
/* Declaram les varibles necessàries */
    DECLARE idJugAnterior SMALLINT UNSIGNED;
    DECLARE idJugSeguent SMALLINT UNSIGNED;
    DECLARE tornAntrior TINYINT UNSIGNED;
    DECLARE tornSeguent TINYINT UNSIGNED;

/* Obrim transacció */
START TRANSACTION;

/* Obtenim la darrera acció de la partida i la que serà la següent*/
    call GetDarreraAccioPrt(_prtId, idJugAnterior, tornAntrior);
    call GetAccioSeguent(_prtId, idJugAnterior, tornAntrior, idJugSeguent, tornSeguent);
    

/* Cream la nova acció amb un INSERT */
    INSERT INTO Accion (turno, tipo, idpartida, idjugador)
    VALUES
    (tornSeguent, "pass", _prtId, idJugSeguent);

/* Associarem les mateixes cartes al tauler que hi havia a l'acció anterior a l'acció que acabam de crear (INSERT-SELECT) */
    INSERT INTO CartaTablero (idcarta, turno, idpartida, idjugador)
    select ct.idcarta, tornSeguent, ct.idpartida, idJugSeguent from CartaTablero ct
    where turno = tornAntrior && idpartida = _prtId && idjugador = idJugAnterior;

    /*Insertamos la accion en la tabla gemaaccion*/
    INSERT INTO GemaAccion (total, variacion, turno, idpartida, idjugador, IdColor)
    select g.total, g.variacion, tornSeguent, g.idpartida, idJugSeguent, g.IdColor from GemaAccion as g
    where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

/* i copiarem les mateixes cartes que tenia abans el jugador a la ma (INSERT-SELECT) */
    INSERT INTO CartaJugador (Reservada, turno, idpartida, idjugador, idcarta)
    select cj.Reservada, tornSeguent, cj.idpartida, idJugSeguent, cj.idcarta from CartaJugador as cj
    where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

/* No modificarem els nobles de la partida perquè en una acció "pass" no s'en captura cap */

COMMIT; /* Confirmam transacció. Ara ja es veuen tots els canvis */
END$$

DELIMITER ;

------------------------------------------------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE DeleteTotesPrt()
BEGIN
    delete from CartaTablero;
    delete from CartaJugador;
    delete from NoblePartida;
    delete from GemaAccion;
    delete from Accion;
    delete from JugadorPartida;
    delete from Partida;

END$$

DELIMITER ;



---------------------------------------------------------------------------------------------------------

/*NovaAccTake2G*/
DROP PROCEDURE NovaAccTake2G;
DELIMITER $$

CREATE PROCEDURE NovaAccTake2G(_prtId INT UNSIGNED, _color ENUM('Red',  'Blue', 'Green', 'White', 'Black'))
BEGIN

    DECLARE idJugAnterior SMALLINT UNSIGNED;
    DECLARE idJugSeguent SMALLINT UNSIGNED;
    DECLARE tornAntrior TINYINT UNSIGNED;
    DECLARE tornSeguent TINYINT UNSIGNED;
    DECLARE numGemTablero TINYINT UNSIGNED DEFAULT 0;
    DECLARE numGemJug TINYINT UNSIGNED;

    /* Obrim transacció */
START TRANSACTION;

/* Obtenim la darrera acció de la partida i la que serà la següent*/
    call GetDarreraAccioPrt(_prtId, idJugAnterior, tornAntrior);
    call GetAccioSeguent(_prtId, idJugAnterior, tornAntrior, idJugSeguent, tornSeguent);
    /*Miramos cuantas gemas hay disponibles y cuantas tiene el jugador*/
    select GemasDisponiblesTablero(_prtId,_color) into numGemTablero;
    select GetNumGemaAcc(_prtId, idJugSeguent, tornSeguent - 1) into numGemJug;


    /*Si el numero de gemas total en mesa es 4 o mas y si el numero de gemas que tiene el jugador es menor a 9*/
IF  numGemTablero >= 4 AND numGemJug < 9  THEN
     /*Creamos una nueva accion de Take2G*/

    INSERT INTO Accion (turno, tipo, idpartida, idjugador)
    VALUES
    (tornSeguent, "take2G", _prtId, idJugSeguent);

    /* Associarem les mateixes cartes al tauler que hi havia a l'acció anterior a l'acció que acabam de crear (INSERT-SELECT) */
    INSERT INTO CartaTablero (idcarta, turno, idpartida, idjugador)
    select ct.idcarta, tornSeguent, ct.idpartida, idJugSeguent from CartaTablero ct
    where turno = tornAntrior && idpartida = _prtId && idjugador = idJugAnterior;

    /*Agafam les gemes del torn anterior de aquest jugador*/
    INSERT INTO GemaAccion (total, variacion, turno, idpartida, idjugador, IdColor)
    select g.total, 0, tornSeguent, g.idpartida, idJugSeguent, g.IdColor from GemaAccion as g
    where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

/*Asignam la variacio dels colors*/  
    UPDATE GemaAccion
    SET 
    total = total + 2, variacion = 2
    where idpartida = _prtId && turno = tornSeguent && idjugador = idJugSeguent && IdColor = _color;

/* i copiarem les mateixes cartes que tenia abans el jugador a la ma (INSERT-SELECT) */
    INSERT INTO CartaJugador (Reservada, turno, idpartida, idjugador, idcarta)
    select cj.Reservada, tornSeguent, cj.idpartida, idJugSeguent, cj.idcarta from CartaJugador as cj
    where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

END IF;
COMMIT;
END$$

DELIMITER ;


-------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$

CREATE FUNCTION SonDiferentes(_color1 ENUM('Red',  'Blue', 'Green', 'White', 'Black'), _color2 ENUM('Red',  'Blue', 'Green', 'White', 'Black'), 
_color3 ENUM('Red',  'Blue', 'Green', 'White', 'Black')) RETURNS TINYINT UNSIGNED
BEGIN

    IF _color1 <> _color2 AND _color1 <> _color3 AND _color2 <> _color3 THEN
    RETURN 1;
    END IF;

    RETURN 0;

END$$
DELIMITER ;

---------------------------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE NovaAccTake3G;
DELIMITER $$

CREATE PROCEDURE NovaAccTake3G(_prtId INT UNSIGNED, _color1 ENUM('Red',  'Blue', 'Green', 'White', 'Black'), _color2 ENUM('Red',  'Blue', 'Green', 'White', 'Black'), 
_color3 ENUM('Red',  'Blue', 'Green', 'White', 'Black'))
BEGIN

    DECLARE idJugAnterior SMALLINT UNSIGNED;
    DECLARE idJugSeguent SMALLINT UNSIGNED;
    DECLARE tornAntrior TINYINT UNSIGNED;
    DECLARE tornSeguent TINYINT UNSIGNED;
    DECLARE numGemColor1 TINYINT UNSIGNED;
    DECLARE numGemColor2 TINYINT UNSIGNED;
    DECLARE numGemColor3 TINYINT UNSIGNED;
    DECLARE numGemJug TINYINT UNSIGNED;
    DECLARE diferentes TINYINT UNSIGNED;



    /* Obrim transacció */
START TRANSACTION;

/* Obtenim la darrera acció de la partida i la que serà la següent*/
    call GetDarreraAccioPrt(_prtId, idJugAnterior, tornAntrior);
    call GetAccioSeguent(_prtId, idJugAnterior, tornAntrior, idJugSeguent, tornSeguent);

    select GemasDisponiblesTablero(_prtId,_color1) into numGemColor1;
    select GemasDisponiblesTablero(_prtId,_color2) into numGemColor2;
    select GemasDisponiblesTablero(_prtId,_color3) into numGemColor3;

    /*Miram el numero de gemes que te el jugador*/
   
    select GetNumGemaAcc(_prtId, idJugSeguent, tornSeguent - 1) into numGemJug;

    /*Miram si els color son diferents*/
    select SonDiferentes(_color1, _color2, _color3) into diferentes;



    /*Si el numero total de gemes en de cada color es major a 0 i el jugador te menys de 8 gemes feim el procediment*/
IF  numGemColor1 > 0 AND numGemColor2 > 0 AND numGemColor3 > 0 AND numGemJug < 8 AND diferentes = 1 THEN
     /*Cream una nova accio de Take3G*/

    INSERT INTO Accion (turno, tipo, idpartida, idjugador)
    VALUES
    (tornSeguent, "take3G", _prtId, idJugSeguent);

    /* Associarem les mateixes cartes al tauler que hi havia a l'acció anterior a l'acció que acabam de crear (INSERT-SELECT) */
    INSERT INTO CartaTablero (idcarta, turno, idpartida, idjugador)
    select ct.idcarta, tornSeguent, ct.idpartida, idJugSeguent from CartaTablero ct
    where turno = tornAntrior && idpartida = _prtId && idjugador = idJugAnterior;



    /*Agafam les gemes del torn anterior de aquest jugador*/
    INSERT INTO GemaAccion (total, variacion, turno, idpartida, idjugador, IdColor)
    select g.total, 0, tornSeguent, g.idpartida, idJugSeguent, g.IdColor from GemaAccion as g
    where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

/*Asignam la variacio dels colors*/  
    UPDATE GemaAccion
    SET 
    total = total + 1, variacion = 1
    where idpartida = _prtId && turno = tornSeguent && idjugador = idJugSeguent && IdColor in (_color1, _color2, _color3);
    

/* i copiarem les mateixes cartes que tenia abans el jugador a la ma (INSERT-SELECT) */
    INSERT INTO CartaJugador (Reservada, turno, idpartida, idjugador, idcarta)
    select cj.Reservada, tornSeguent, cj.idpartida, idJugSeguent, cj.idcarta from CartaJugador as cj
    where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

END IF;
COMMIT;
END$$

DELIMITER ;


-----------------------------------------------------------------------------------------------------------

    DELIMITER $$

    DROP FUNCTION GemasDisponiblesTablero$$

    CREATE FUNCTION GemasDisponiblesTablero(_prtId INT UNSIGNED, _color ENUM('Red',  'Blue', 'Green', 'White', 'Black','Gold'))
    RETURNS TINYINT UNSIGNED

    BEGIN
        DECLARE numGemTablero TINYINT UNSIGNED DEFAULT 0;
        DECLARE numGemColor TINYINT UNSIGNED DEFAULT 0;
        DECLARE idJugAnterior SMALLINT UNSIGNED;
        DECLARE tornAntrior TINYINT UNSIGNED;
        DECLARE idJug SMALLINT UNSIGNED;
        DECLARE accioAnterior SMALLINT UNSIGNED;
        DECLARE numJug TINYINT UNSIGNED;
        DECLARE num TINYINT UNSIGNED DEFAULT 0;

        /*Miram quina es la darrera accio y el darrer jugador de la partida*/
        call GetDarreraAccioPrt(_prtId, idJugAnterior, tornAntrior);
        select GetNumJugPrt(_prtId) into numJug;

        set accioAnterior = tornAntrior;
        set idJug = idJugAnterior;

        
        WHILE numJug > 0 DO
        /*Guardam la cantidad de gemes de el color que te el jugador i les sumam*/
            select GetNumGemColAcc(_color, _prtId, idJug, accioAnterior) into num;
            set numGemTablero = num + numGemTablero;
            /*Canviam al jugador anterior*/
            call GetAccioAnterior(_prtId, idJug, accioAnterior, idJug, accioAnterior);
            set numJug = numJug - 1;
        END WHILE;

        /*Restam les gemes totales que hi ha a la partida per les que tenen els jugadors*/
        select GetNumGemesClrENJoc(_prtId, _color) into numGemColor;
        set numGemTablero =  numGemColor - numGemTablero;

    RETURN numGemTablero;
    END$$
    DELIMITER ;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP FUNCTION GetCrtNivell$$

/*Funcio per trobar la següent carta disponible per posar al tauler*/
CREATE FUNCTION GetCrtNivell(_prtId INT UNSIGNED, _nivell TINYINT UNSIGNED) RETURNS VARCHAR(20)
BEGIN
    DECLARE id VARCHAR(20) DEFAULT NULL;
    DECLARE turnoLast TINYINT UNSIGNED;
    DECLARE idJug SMALLINT UNSIGNED;
    
    call GetDarreraAccioPrt(_prtId, idJug, turnoLast);

    SELECT idcarta INTO id FROM carta
    WHERE Nivel = _nivell AND idcarta NOT IN (
        SELECT ct.idcarta FROM CartaTablero AS ct
        where idpartida = _prtId AND nivel = _nivell
        UNION
        SELECT cj.idcarta from CartaJugador as cj
        where idpartida = _prtId AND nivel = _nivell
    )
    ORDER BY RAND()
    limit 1;


    RETURN id;
END$$
DELIMITER ;

-------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP PROCEDURE CartaComprableAcc$$

CREATE PROCEDURE CartaComprableAcc(
    _prtId INT UNSIGNED,
    _idcarta VARCHAR(20),
    OUT _comprable BOOLEAN,
    OUT _TM ENUM ('T', 'MR')
)
BEGIN
    DECLARE idJugAnterior SMALLINT UNSIGNED;
    DECLARE idJugSeguent SMALLINT UNSIGNED;
    DECLARE turnoSig TINYINT UNSIGNED;
    DECLARE turnoAnt TINYINT UNSIGNED;

    DECLARE numCantidadVerde TINYINT DEFAULT 0;
    DECLARE numCantidadRoja TINYINT DEFAULT 0;
    DECLARE numCantidadAzul TINYINT DEFAULT 0;
    DECLARE numCantidadNegra TINYINT DEFAULT 0;
    DECLARE numCantidadBlanca TINYINT DEFAULT 0;
    DECLARE numCantidadDorada TINYINT DEFAULT -1;

    DECLARE costeVerde TINYINT DEFAULT 0;
    DECLARE costeRoja TINYINT DEFAULT 0;
    DECLARE costeAzul TINYINT DEFAULT 0;
    DECLARE costeNegra TINYINT DEFAULT 0;
    DECLARE costeBlanca TINYINT DEFAULT 0;

    DECLARE cartaTrobada VARCHAR(20);

    call GetDarreraAccioPrt(_prtId, idJugAnterior, turnoAnt);
    call GetAccioSeguent(_prtId, idJugAnterior, turnoAnt, idJugSeguent, turnoSig);

    /*Miram si la carta esta a la ma del jugador o la taula*/
    SET _TM = NULL;


    select idcarta into cartaTrobada from cartatablero
    where idcarta = _idcarta && idpartida = _prtId && turno = turnoAnt && idjugador = idJugAnterior;

    /*Si hem trobat la carta al tauler posam la variable _TM com a 'T'*/
    IF cartaTrobada IS NOT NULL THEN
        SET _TM = 'T';
    ELSE 
        select idcarta into cartaTrobada from CartaJugador
        where idcarta = _idcarta && idpartida = _prtId && turno = turnoSig - 1 && Reservada = 1 && IdJugador = idJugSeguent;
        /*Si hem trobat la carta a la del jugador posam la variable _TM com a 'TM', sino quedara com a NULL*/
        IF cartaTrobada IS NOT NULL THEN
            SET _TM = 'MR';
        END IF;
    END IF;


    IF cartaTrobada IS NOT NULL THEN
    /*Miram el cost de la carta*/
    select coste into costeRoja from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'Red';

    select coste into costeVerde from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'Green';
    
    select coste into costeAzul from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'Blue';
    
    select coste into costeNegra from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'Black';
    
    select coste into costeBlanca from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'White';


    /*Miram el poder de compra que te el jugador*/
    select GetPowerColAcc('Red', _prtId, idJugSeguent, turnoSig - 1) into numCantidadRoja;
    select GetPowerColAcc('Green', _prtId, idJugSeguent, turnoSig - 1) into numCantidadVerde;
    select GetPowerColAcc('Blue', _prtId, idJugSeguent, turnoSig - 1) into numCantidadAzul;
    select GetPowerColAcc('Black', _prtId, idJugSeguent, turnoSig - 1) into numCantidadNegra;
    select GetPowerColAcc('White', _prtId, idJugSeguent, turnoSig - 1) into numCantidadBlanca;
    select GetNumGemColAcc('Gold', _prtId, idJugSeguent, turnoSig - 1) into numCantidadDorada;

    /*Comprovam si la pot comprar*/
    /*Si el cost es major a la cantidad de les gemes li restam a les dorades*/
    IF numCantidadRoja < costeRoja THEN
        SET numCantidadDorada = (numCantidadDorada + numCantidadRoja) - costeRoja;
    END IF;
    IF numCantidadVerde < costeVerde THEN
        SET numCantidadDorada = (numCantidadDorada + numCantidadVerde) - costeVerde;
    END IF;
    IF numCantidadAzul < costeAzul THEN
        SET numCantidadDorada = (numCantidadDorada + numCantidadAzul) - costeAzul;
    END IF;
    IF numCantidadNegra < costeNegra THEN
        SET numCantidadDorada = (numCantidadDorada + numCantidadNegra) - costeNegra;
    END IF;
    IF numCantidadBlanca < costeBlanca THEN
        SET numCantidadDorada = (numCantidadDorada + numCantidadBlanca) - costeBlanca;
    END IF;
END IF;
    /*Sempre que la cantidad de gemes dorades restants siguin majors a -1 es podra comprar la carta*/
    SET _comprable = numCantidadDorada > -1;
END$$
DELIMITER ;

---------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP PROCEDURE NovaAccBuy$$

CREATE PROCEDURE NovaAccBuy(_prtId SMALLINT UNSIGNED, _idcarta VARCHAR(20))
BEGIN
    DECLARE posicionCarta ENUM ('T', 'MR');
    DECLARE comprable BOOLEAN;
    DECLARE idJugAnterior SMALLINT UNSIGNED;
    DECLARE idJugSeguent SMALLINT UNSIGNED;
    DECLARE turnoSig TINYINT UNSIGNED;
    DECLARE turnoAnt TINYINT UNSIGNED;

    DECLARE pagoRoja TINYINT DEFAULT 0;
    DECLARE pagoNegra TINYINT DEFAULT 0;
    DECLARE pagoBlanca TINYINT DEFAULT 0;
    DECLARE pagoVerde TINYINT DEFAULT 0;
    DECLARE pagoAzul TINYINT DEFAULT 0;

    DECLARE nivelCarta ENUM ('1','2','3');
    DECLARE novaCarta VARCHAR(20);

    DECLARE costeVerde TINYINT DEFAULT 0;
    DECLARE costeRoja TINYINT DEFAULT 0;
    DECLARE costeAzul TINYINT DEFAULT 0;
    DECLARE costeNegra TINYINT DEFAULT 0;
    DECLARE costeBlanca TINYINT DEFAULT 0;

    DECLARE numCantidadVerde TINYINT DEFAULT 0;
    DECLARE numCantidadRoja TINYINT DEFAULT 0;
    DECLARE numCantidadAzul TINYINT DEFAULT 0;
    DECLARE numCantidadNegra TINYINT DEFAULT 0;
    DECLARE numCantidadBlanca TINYINT DEFAULT 0;

    DECLARE totalNegra TINYINT DEFAULT 0;
    DECLARE totalBlanca TINYINT DEFAULT 0;
    DECLARE totalRoja TINYINT DEFAULT 0;
    DECLARE totalVerde TINYINT DEFAULT 0;
    DECLARE totalAzul TINYINT DEFAULT 0;

    DECLARE totalCrtNegra TINYINT DEFAULT 0;
    DECLARE totalCrtBlanca TINYINT DEFAULT 0;
    DECLARE totalCrtRoja TINYINT DEFAULT 0;
    DECLARE totalCrtVerde TINYINT DEFAULT 0;
    DECLARE totalCrtAzul TINYINT DEFAULT 0;

    DECLARE variacioDorades TINYINT DEFAULT 0;
    DECLARE numCantidadDorada TINYINT DEFAULT 0;

    START TRANSACTION;

    select "cartes copiades al tauler";

    call GetDarreraAccioPrt(_prtId, idJugAnterior, turnoAnt);
    call GetAccioSeguent(_prtId, idJugAnterior, turnoAnt, idJugSeguent, turnoSig);

    /*Miram la cantidad de gemes que te el jugador*/
    select total into totalNegra from gemaaccion
    where idcolor = 'Black' AND idpartida = _prtId AND idjugador = idJugSeguent AND turno = turnoSig - 1;

    select total into totalBlanca from gemaaccion
    where idcolor = 'White' AND idpartida = _prtId AND idjugador = idJugSeguent AND turno = turnoSig - 1;

    select total into totalRoja from gemaaccion
    where idcolor = 'Red' AND idpartida = _prtId AND idjugador = idJugSeguent AND turno = turnoSig - 1;

    select total into totalVerde from gemaaccion
    where idcolor = 'Green' AND idpartida = _prtId AND idjugador = idJugSeguent AND turno = turnoSig - 1;

    select total into totalAzul from gemaaccion
    where idcolor = 'Blue' AND idpartida = _prtId AND idjugador = idJugSeguent AND turno = turnoSig - 1;

    select total into numCantidadDorada from gemaaccion
    where idcolor = 'Gold' AND idpartida = _prtId AND idjugador = idJugSeguent AND turno = turnoSig - 1;

    /*Miram el cost de la carta*/
    select coste into costeRoja from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'Red';

    select coste into costeVerde from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'Green';
    
    select coste into costeAzul from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'Blue';
    
    select coste into costeNegra from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'Black';
    
    select coste into costeBlanca from CosteCarta 
    where idcarta = _idcarta AND IdColor = 'White';

    /*Comprovam que la carta es comprable*/
    call CartaComprableAcc(_prtId, _idcarta, comprable, posicionCarta);

    /*Si la carta es comprable feim el procediment*/
    IF comprable = 1 THEN
    
        /*Cream la nova accio de compra*/
        INSERT INTO Accion (turno, tipo, idpartida, idjugador)
        VALUES
        (turnoSig, "Buy", _prtId, idJugSeguent);
        

        /*Posam les cartes al tauler*/
        INSERT INTO CartaTablero (idcarta, turno, idpartida, idjugador)
        select ct.idcarta, turnoSig, _prtId, idJugSeguent from CartaTablero ct
        where turno = turnoAnt && idpartida = _prtId && idjugador = idJugAnterior;

        

        /*Agafam les cartes del jugador de el torn anterior*/
        INSERT INTO CartaJugador (Reservada, turno, idpartida, idjugador, idcarta)
        select cj.Reservada, turnoSig, cj.idpartida, idJugSeguent, cj.idcarta from CartaJugador as cj
        where idpartida = _prtId && turno = turnoSig - 1 && idjugador = idJugSeguent;

        /*Agafam les gemes de laccio anterior*/
        INSERT INTO GemaAccion (total, variacion, turno, idpartida, idjugador, IdColor)
        select g.total , 0, turnoSig, g.idpartida, idJugSeguent, g.IdColor from GemaAccion as g
        where idpartida = _prtId && turno = turnoSig - 1 && idjugador = idJugSeguent;


        IF posicionCarta = 'T' THEN
            /*Ara que ja sabem que es comprable i que la carta esta en el tauler, insertam la carta a la ma del jugador*/
            insert into CartaJugador(Reservada, turno, idpartida, idjugador, idcarta)
            VALUES 
            (0, turnoSig, _prtId, idJugSeguent, _idcarta);

            /*Agafam la següent carta disponible per posar al tauler*/
            select nivel into nivelCarta from carta
            where idcarta = _idcarta;

            select GetCrtNivell(_prtId, nivelCarta) into novaCarta;

            IF novaCarta IS NOT NULL THEN
                UPDATE cartatablero
                SET idcarta = novaCarta
                where idcarta = _idcarta AND idpartida = _prtId AND turno = turnoSig AND idjugador = idJugSeguent;
            ELSE 
                DELETE FROM CartaTablero where idcarta = _idcarta AND idpartida = _prtId AND turno = turnoSig AND idjugador = idJugSeguent;
            END IF;
                ELSE
                    /*Si la carta no esta al tauler estara a la ma del jugador, cream la nova accio de buyholded*/
                    UPDATE Accion
                    SET tipo = 'BuyHolded'
                    where turno = turnoSig AND tipo = 'Buy' AND idpartida = _prtId AND idjugador = idJugSeguent;

                    /*Actualitzam la ma del jugador i posam la carta que era reservada com a comprada*/
                    UPDATE CartaJugador
                    SET Reservada = 0
                    where idcarta = _idcarta AND idjugador = idJugSeguent AND idpartida = _prtId AND turno = turnoSig;
        END IF;

        /*Miram el cost de cada color, en cas de que tengui cost, primer mirarem si ens basta sense les gemes dorades, sino, li resterem les necesaries*/
        IF costeAzul > 0 THEN
            /*Miram la cantidad de poder de un color que te el jugador*/
            select GetPowerColAcc('Blue', _prtId, idJugSeguent, turnoSig - 1) into numCantidadAzul;
            
            /*Miram la cantidad de cartes que te dun color*/
            select GetNumCartesColAcc('Blue', _prtId, idJugSeguent, turnoSig - 1) into totalCrtAzul;

            /*Miram el cost de les gemes*/
            set pagoAzul = costeAzul - totalCrtAzul;

            /*Si el cost es major que les gemes que tenim fara falta utilitzar les gemes dorades*/
            IF pagoAzul > totalAzul THEN
                set variacioDorades = variacioDorades + (pagoAzul - totalAzul);
                set numCantidadDorada = numCantidadDorada - (pagoAzul - totalAzul);
                set pagoAzul = totalAzul;
            END IF;

            /*Domes farem UPDATE si pagoAzul es major que 0*/
            IF pagoAzul > 0 THEN
                UPDATE gemaaccion
                SET total = totalAzul - pagoAzul , variacion = -pagoAzul
                where idpartida = _prtId AND turno = turnoSig AND idjugador = idJugSeguent AND IdColor = 'Blue';
            END IF;
        END IF;

        IF costeRoja > 0 THEN
            select GetPowerColAcc('Red', _prtId, idJugSeguent, turnoSig - 1) into numCantidadRoja;
           
            select GetNumCartesColAcc('Red', _prtId, idJugSeguent, turnoSig - 1) into totalCrtRoja;

            set pagoRoja = costeRoja - totalCrtRoja;

            IF pagoRoja > totalRoja THEN
                set variacioDorades = variacioDorades + (pagoRoja - totalRoja);
                set numCantidadDorada = numCantidadDorada - (pagoRoja - totalRoja);
                set pagoRoja = totalRoja;
            END IF;

            IF pagoRoja > 0 THEN
                UPDATE gemaaccion
                SET total = totalRoja - pagoRoja , variacion = -pagoRoja
                where idpartida = _prtId AND turno = turnoSig AND idjugador = idJugSeguent AND IdColor = 'Red';
            END IF;
        END IF;

        IF costeVerde > 0 THEN
            select GetPowerColAcc('Green', _prtId, idJugSeguent, turnoSig - 1) into numCantidadVerde;
            select GetNumCartesColAcc('Green', _prtId, idJugSeguent, turnoSig - 1) into totalCrtVerde;

            set pagoVerde = costeVerde - totalCrtVerde;

            IF pagoVerde > totalVerde THEN
                set variacioDorades = variacioDorades + (pagoVerde - totalVerde);
                set numCantidadDorada = numCantidadDorada - (pagoVerde - totalVerde);
                set pagoVerde = totalVerde;
            END IF;

            IF pagoVerde > 0 THEN
                UPDATE gemaaccion
                SET total = totalVerde - pagoVerde , variacion = -pagoVerde
                where idpartida = _prtId AND turno = turnoSig AND idjugador = idJugSeguent AND IdColor = 'Green';
            END IF;
        END IF;

        IF costeNegra > 0 THEN
            select GetPowerColAcc('Black', _prtId, idJugSeguent, turnoSig - 1) into numCantidadNegra;
            select GetNumCartesColAcc('Black', _prtId, idJugSeguent, turnoSig - 1) into totalCrtNegra;

            set pagoNegra = costeNegra - totalCrtNegra;

            IF pagoNegra > totalNegra THEN
                set variacioDorades = variacioDorades + (pagoNegra - totalNegra);
                set numCantidadDorada = numCantidadDorada - (pagoNegra - totalNegra);
                set pagoNegra = totalNegra;
            END IF;

            IF pagoNegra > 0 THEN
                UPDATE gemaaccion
                SET total = totalNegra - pagoNegra , variacion = -pagoNegra
                where idpartida = _prtId AND turno = turnoSig AND idjugador = idJugSeguent AND IdColor = 'Black';
            END IF;
        END IF;

        IF costeBlanca > 0 THEN
            select GetPowerColAcc('White', _prtId, idJugSeguent, turnoSig - 1) into numCantidadBlanca;
            select GetNumCartesColAcc('White', _prtId, idJugSeguent, turnoSig - 1) into totalCrtBlanca;

            set pagoBlanca = costeBlanca - totalCrtBlanca;

            IF pagoBlanca > totalBlanca THEN
                set variacioDorades = variacioDorades + (pagoBlanca - totalBlanca);
                set numCantidadDorada = numCantidadDorada - (pagoBlanca - totalBlanca);
                set pagoBlanca = totalBlanca;
            END IF;

            IF pagoBlanca > 0 THEN
                UPDATE gemaaccion
                SET total = totalBlanca - pagoBlanca , variacion = -pagoBlanca
                where idpartida = _prtId AND turno = turnoSig AND idjugador = idJugSeguent AND IdColor = 'White';
            END IF;
        END IF;

        /*Feim el canvi de les gemes dorades*/
        UPDATE gemaaccion
        SET total = numCantidadDorada, variacion = -variacioDorades
        where idpartida = _prtId AND turno = turnoSig AND idjugador = idJugSeguent AND IdColor = 'Gold';

        /*Miram si el jugador pot adquirir algun noble*/
        call GetNoble(_prtId, idJugSeguent, turnoSig);

    END IF;

COMMIT;
END$$
DELIMITER ;

-----------------------------------------------------------------------------------------------------------------------------------------------



DELIMITER $$

DROP PROCEDURE NovaAccHold$$

CREATE PROCEDURE NovaAccHold(_prtId SMALLINT UNSIGNED, _idcarta VARCHAR(20))
BEGIN
    
    DECLARE idJugAnterior SMALLINT UNSIGNED;
    DECLARE idJugSeguent SMALLINT UNSIGNED;
    DECLARE tornAntrior TINYINT UNSIGNED;
    DECLARE tornSeguent TINYINT UNSIGNED;
    DECLARE posicion ENUM('T','MR');
    DECLARE disponible BOOLEAN;
    DECLARE gemasDoradasTablero TINYINT UNSIGNED DEFAULT 0;

    DECLARE nuevaCartaNivel VARCHAR(20);
    DECLARE nivelC ENUM('1','2','3');
    DECLARE numCartesRes TINYINT UNSIGNED;
    DECLARE numGemesTotals TINYINT UNSIGNED;

    START TRANSACTION;

    /* Obtenim la darrera acció de la partida i la que serà la següent*/
    call GetDarreraAccioPrt(_prtId, idJugAnterior, tornAntrior);
    call GetAccioSeguent(_prtId, idJugAnterior, tornAntrior, idJugSeguent, tornSeguent);

    /*Miram si la carta esta en el tauler i la cantidad de gemes dorades que hi ha en el tauler*/
    call CartaComprableAcc(_prtId, _idcarta, disponible, posicion);
    select GemasDisponiblesTablero(_prtId, 'Gold') into gemasDoradasTablero;

    /*Saber cuantes cartes reservades te i cuantes gemes te el jugador*/
    select count(*) into numCartesRes from CartaJugador
    where reservada = 1 AND idjugador = idJugSeguent AND idpartida = _prtId AND turno = tornSeguent - 1;

    select GetNumGemaAcc(_prtId, idJugSeguent, tornSeguent - 1) into numGemesTotals;

    /*Si la carta esta en el tauler, hi ha alemnys una gema dorada al tauler, te menys de 3 cartes reservades y menys de 10 gemes, farem el procediment*/
    IF posicion = 'T' AND gemasDoradasTablero > 0 AND numCartesRes < 3 AND numGemesTotals < 10 THEN
        /*Cream la nova accio de compra*/
        INSERT INTO Accion (turno, tipo, idpartida, idjugador)
        VALUES
        (tornSeguent, "Hold", _prtId, idJugSeguent);

        /*Posam les cartes al tauler*/
        INSERT INTO CartaTablero (idcarta, turno, idpartida, idjugador)
        select ct.idcarta, tornSeguent, _prtId, idJugSeguent from CartaTablero ct
        where turno = tornAntrior && idpartida = _prtId && idjugador = idJugAnterior;

        /*Agafam les cartes del jugador de el torn anterior*/
        INSERT INTO CartaJugador (Reservada, turno, idpartida, idjugador, idcarta)
        select cj.Reservada, tornSeguent, cj.idpartida, idJugSeguent, cj.idcarta from CartaJugador as cj
        where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

        /*Agafam les gemes de laccio anterior*/
        INSERT INTO GemaAccion (total, variacion, turno, idpartida, idjugador, IdColor)
        select g.total, 0, tornSeguent, g.idpartida, idJugSeguent, g.IdColor from GemaAccion as g
        where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

        /*Miram el nivell de la carta i agafam una altre per sustituirla*/
        select nivel into nivelC from carta
        where idcarta = _idcarta;

        select GetCrtNivell(_prtId, nivelC) into nuevaCartaNivel;

        IF nuevaCartaNivel IS NOT NULL THEN
            UPDATE CartaTablero
            SET idcarta = nuevaCartaNivel
            where idcarta = _idcarta AND turno = tornSeguent AND idpartida = _prtId AND idjugador = idJugSeguent;
        ELSE 
            DELETE FROM cartatablero where idcarta = _idcarta AND turno = tornSeguent AND idpartida = _prtId AND idjugador = idJugSeguent;
        END IF;

        /*Posam la carta a la ma del jugador i li donam una gema dorada*/
        INSERT INTO CartaJugador
        VALUES
        (1, tornSeguent, _prtId, idJugSeguent, _idcarta);

        UPDATE GemaAccion
        SET total = total + 1, variacion = 1
        where turno = tornSeguent AND idpartida = _prtId AND idjugador = idJugSeguent AND IdColor = 'Gold';

    END IF;
    COMMIT;
    END$$
    DELIMITER ;

-------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$
DROP PROCEDURE GetNoble$$

CREATE PROCEDURE GetNoble(_prtId SMALLINT UNSIGNED, _idJugador SMALLINT UNSIGNED, _torn TINYINT UNSIGNED)
BEGIN

    DECLARE numCantidadVerde TINYINT DEFAULT 0;
    DECLARE numCantidadRoja TINYINT DEFAULT 0;
    DECLARE numCantidadAzul TINYINT DEFAULT 0;
    DECLARE numCantidadNegra TINYINT DEFAULT 0;
    DECLARE numCantidadBlanca TINYINT DEFAULT 0;

    DECLARE costeVerdeNoble TINYINT DEFAULT 0;
    DECLARE costeRojaNoble TINYINT DEFAULT 0;
    DECLARE costeAzulNoble TINYINT DEFAULT 0;
    DECLARE costeNegroNoble TINYINT DEFAULT 0;
    DECLARE costeBlancaNoble TINYINT DEFAULT 0;

    DECLARE id TINYINT UNSIGNED;
    DECLARE final TINYINT UNSIGNED DEFAULT 0;

    DECLARE CursNobl CURSOR FOR
    select IdNoble from NoblePartida
    where idpartida = _prtId AND idjugador IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET final = 1;

    START TRANSACTION;


        /*Saber el poder que te el jugador de cada color*/
        select GetNumCartesColAcc('Red', _prtId, _idJugador, _torn) into numCantidadRoja;
        select GetNumCartesColAcc('Blue', _prtId, _idJugador, _torn) into numCantidadAzul;
        select GetNumCartesColAcc('Black', _prtId, _idJugador, _torn) into numCantidadNegra;
        select GetNumCartesColAcc('White', _prtId, _idJugador, _torn) into numCantidadBlanca;
        select GetNumCartesColAcc('Green', _prtId, _idJugador, _torn) into numCantidadVerde;

        /*Comprobam si el cost del noble coincideix amb el poder del jugador*/
        OPEN CursNobl;
            getCoste: LOOP
            SET costeAzulNoble = 0;
            SET costeRojaNoble = 0;
            SET costeNegroNoble = 0;
            SET costeBlancaNoble = 0;
            SET costeVerdeNoble = 0;
            
            SET final = 0;
            FETCH CursNobl into id;
    
            IF final = 1 THEN
                LEAVE getCoste;
            END IF;

            /*Guardam els costos del noble actual del cursor*/
            select coste into costeAzulNoble from costenobles
            where IdNoble = id AND IdColor = 'Blue';

            select coste into costeRojaNoble from costenobles
            where IdNoble = id AND IdColor = 'Red';

            select coste into costeNegroNoble from costenobles
            where IdNoble = id AND IdColor = 'Black';

            select coste into costeBlancaNoble from costenobles
            where IdNoble = id AND IdColor = 'White';

            select coste into costeVerdeNoble from costenobles
            where IdNoble = id AND IdColor = 'Green';

            /*Comprovam que el jugador tengui el suficient poder per poder-lo adquirir*/
            IF numCantidadAzul >= costeAzulNoble AND numCantidadBlanca >= costeBlancaNoble AND numCantidadVerde >= costeVerdeNoble 
            AND numCantidadNegra >= costeNegroNoble AND numCantidadRoja >= costeRojaNoble THEN
            /*Feim l'update de la taula noblepartida per fer que apunti al jugador que el te capturat*/
                UPDATE NoblePartida
                SET turno = _torn, idpartidaaccion = _prtId, idjugador = _idJugador
                where IdNoble = id AND idpartida = _prtId;
            END IF;

        END LOOP getCoste;
        CLOSE CursNobl;

COMMIT;
END$$
DELIMITER ;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$

DROP PROCEDURE NovaAccBlindHold$$

CREATE PROCEDURE NovaAccBlindHold(_prtId SMALLINT UNSIGNED, _nivel ENUM('1','2','3'))
BEGIN

    DECLARE idJugAnterior SMALLINT UNSIGNED;
    DECLARE idJugSeguent SMALLINT UNSIGNED;
    DECLARE tornAntrior TINYINT UNSIGNED;
    DECLARE tornSeguent TINYINT UNSIGNED;

    DECLARE idCartaNova VARCHAR(20);
    DECLARE numGemDoradaTauler TINYINT UNSIGNED DEFAULT 0;
    DECLARE numCartesRes TINYINT UNSIGNED DEFAULT 0;
    DECLARE numGemesTotals TINYINT UNSIGNED DEFAULT 0;

    START TRANSACTION;

    /* Obtenim la darrera acció de la partida i la que serà la següent*/
    call GetDarreraAccioPrt(_prtId, idJugAnterior, tornAntrior);
    call GetAccioSeguent(_prtId, idJugAnterior, tornAntrior, idJugSeguent, tornSeguent);

    /*Treim les gemes dorades que hi ha al tauler*/
    select GemasDisponiblesTablero(_prtId, 'Gold') into numGemDoradaTauler;

    /*Miram el numero de cartes reservades que te el jugador*/
    select count(*) into numCartesRes from CartaJugador
    where reservada = 1 AND idjugador = idJugSeguent AND idpartida = _prtId AND turno = tornSeguent - 1;

    /*Miram el numero de gemes totals que te el jugador*/
    select GetNumGemaAcc(_prtId, idJugSeguent, tornSeguent - 1) into numGemesTotals;

    SET idCartaNova = NULL;

    /*Treure la seguent carta disponible del mateix nivell*/
    select GetCrtNivell(_prtId, _nivel) into idCartaNova;

    /*Si hi ha una carta disponible de aquell nivell, al tauler hi ha almenys una gema dorada, el jugador te menys de 3 cartes reservades y te menys de 10 gemes farem la accio*/
    IF idCartaNova IS NOT NULL AND numGemDoradaTauler > 0 AND numCartesRes < 3 AND numGemesTotals < 10 THEN
        /*Cream la nova accio de compra*/
        INSERT INTO Accion (turno, tipo, idpartida, idjugador)
        VALUES
        (tornSeguent, "Hold", _prtId, idJugSeguent);

        /*Posam les cartes al tauler*/
        INSERT INTO CartaTablero (idcarta, turno, idpartida, idjugador)
        select ct.idcarta, tornSeguent, _prtId, idJugSeguent from CartaTablero ct
        where turno = tornAntrior && idpartida = _prtId && idjugador = idJugAnterior;

        /*Agafam les cartes del jugador de el torn anterior*/
        INSERT INTO CartaJugador (Reservada, turno, idpartida, idjugador, idcarta)
        select cj.Reservada, tornSeguent, cj.idpartida, idJugSeguent, cj.idcarta from CartaJugador as cj
        where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

        /*Agafam les gemes de laccio anterior*/
        INSERT INTO GemaAccion (total, variacion, turno, idpartida, idjugador, IdColor)
        select g.total, 0, tornSeguent, g.idpartida, idJugSeguent, g.IdColor from GemaAccion as g
        where idpartida = _prtId && turno = tornSeguent - 1 && idjugador = idJugSeguent;

        /*Posam la carta a la ma del jugador*/
        INSERT INTO CartaJugador
        VALUES
        (1, tornSeguent, _prtId, idJugSeguent, idCartaNova);

        /*Li donam una gema dorada al jugador*/
        UPDATE GemaAccion
        SET total = total + 1, variacion = 1
        where turno = tornSeguent AND idpartida = _prtId AND idjugador = idJugSeguent AND IdColor = 'Gold';

    END IF;

COMMIT;
END$$
DELIMITER ;

-----------------------------------------------------------------------------------------------------------------------------------

DELIMITER $$


CREATE FUNCTION GetNumCrtAcc(_prtId SMALLINT UNSIGNED, _id SMALLINT UNSIGNED, _torn TINYINT UNSIGNED) RETURNS TINYINT UNSIGNED
BEGIN
    DECLARE countCrt TINYINT UNSIGNED DEFAULT 0;

    select count(*) into countCrt from CartaJugador
    where idjugador = _id AND idpartida = _prtId AND turno = _torn;

    RETURN countCrt;

END $$
DELIMITER ;

---------------------------------------------------------------------------------------------------------------------------------------

DROP FUNCTION GameIsOver;
DELIMITER $$

/* Funció que permet saber si la partida ha acabat.
Per una partida acabada retorna l'id del guanyador, per una partida no acabada retorna NULL. */
CREATE FUNCTION GameIsOver(
    _prtId SMALLINT UNSIGNED
) RETURNS INT
BEGIN
    DECLARE obj          TINYINT UNSIGNED;
    DECLARE numJugs      TINYINT UNSIGNED;
    DECLARE jugIdLast    INT UNSIGNED;
    DECLARE tornLast     TINYINT UNSIGNED;
    DECLARE posLast      TINYINT UNSIGNED;
    DECLARE idWinner     INT;
    DECLARE cont         TINYINT UNSIGNED DEFAULT 1;
    DECLARE unIdJug      INT UNSIGNED;
    DECLARE puntsJug     TINYINT UNSIGNED;
    DECLARE numCrtJug    TINYINT UNSIGNED;
    DECLARE numGoldenJug TINYINT UNSIGNED;
    DECLARE maxPunts     TINYINT DEFAULT -1;
    DECLARE minCartes    TINYINT UNSIGNED DEFAULT 255;
    DECLARE minDaurades  TINYINT UNSIGNED DEFAULT 255;
    
    DECLARE cJugs CURSOR FOR
        SELECT  idjugador, GetPuntJgdrAcc(_prtId, idjugador, tornLast),
                GetNumCrtAcc(_prtId, idjugador, tornLast),
                GetNumGemColAcc('golden', _prtId, idjugador, tornLast) 
            FROM jugadorpartida
            WHERE idpartida = _prtId
            ORDER BY orden;

    /* Obtenim la darrera acció executada. Per poder donar la partida per conclosa han d'haver jugat tots els jugadors */
    CALL GetDarreraAccioPrt( _prtId, jugIdLast, tornLast );
    
    /* Obtenim l'ordre de joc del darrer jugador */
    SELECT orden INTO posLast
        FROM jugadorpartida
        WHERE idpartida = _prtId AND idjugador = jugIdLast;
    
    /* Obtenim el nombre de jugadors presents a la partida */
    SELECT GetNumJugPrt(_prtId) INTO numJugs;
    
    /* Si ja han jugat tots els jugadors en aquest torn */
    IF posLast = numJugs THEN
        /* Obtenim els punts de victòria mínims requerits per guanyar una partida */
        SELECT Puntuacion INTO obj
            FROM Partida
            WHERE idpartida = _prtId;
    END IF;

        SET idWinner = -1;
        OPEN cJugs;
        
        WHILE cont <= numJugs DO 
            FETCH cJugs INTO unIdJug, puntsJug, numCrtJug,numGoldenJug; 

            IF puntsJug >= obj THEN
                IF puntsJug > maxPunts THEN
                    SET idWinner    = unIdJug;
                    SET maxPunts    = puntsJug;
                    SET minCartes   = numCrtJug;
                    SET minDaurades = numGoldenJug;
                ELSEIF puntsJug = maxPunts THEN
                    IF numCrtJug < minCartes THEN
                        SET idWinner    = unIdJug;
                        SET maxPunts    = puntsJug;
                        SET minCartes   = numCrtJug;
                        SET minDaurades = numGoldenJug;
                    ELSEIF numCrtJug = minCartes THEN
                        IF numGoldenJug <= minDaurades THEN
                            SET idWinner    = unIdJug;
                            SET maxPunts    = puntsJug;
                            SET minCartes   = numCrtJug;
                            SET minDaurades = numGoldenJug;                        
                        END IF;
                    END IF;
                END IF;
            END IF;

            SET cont = cont + 1;
        END WHILE;
        CLOSE cJugs;
   
    RETURN idWinner;
END$$
DELIMITER ;

------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS addPuntos;
DELIMITER $$
CREATE FUNCTION addPuntos(
    _prtId SMALLINT UNSIGNED
) RETURNS BOOLEAN
BEGIN
    DECLARE idJugGanador INT UNSIGNED;

    SET idJugGanador = GameIsOver(_prtId);

    IF idJugGanador > 0 THEN
        update jugador
        SET rango = rango + 50
        where idjugador = idJugGanador;
        RETURN true;
    END IF;

    RETURN false;

END$$
DELIMITER ;

------------------------------------------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER EncriptarContrasenya
BEFORE INSERT ON jugador
FOR EACH ROW
BEGIN
    SET NEW.contrasenya = SHA1(NEW.contrasenya);
END $$

DELIMITER ;
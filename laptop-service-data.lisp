;;; -*- Mode:Common-Lisp; Package:USER; Base:10 -*-

;;feature: OUTLET = reprezinta incercarea incarcarii intr-o alta priza; valori: YES(s-a incercat alta priza), 
;;										NO(nu s-a incercat alta priza);
;;
;;	   POWERCORD = reprezinta cablul de alimentare; valori: TEAR(cablu rupt), 
;;								DENT(cablu taiat),
;;								WORN(cablu uzat),
;;								NORMAL(cablu fara probleme);	
;; 
;; 	   POWERBRICK = reprezinta acumulatorul incarcatorului; valori: SMELL(acumulatorul este deformat),
;;	                                                                WARP(acumulatorul miroase a plastic ars),
;;                                                                      NORMAL(acumulator fara probleme);
;;
;;
;;	   CONNECTION = reprezinta mufa de incarcare; valori: DETACHMENT(mufa de incarcare joaca),
;;							      DAMAGE(mufa de incarcare avariata),
;;							      NORMAL(mufa de incarcare fara probleme);
;;	   
;;	   VENT = reprezinta necesitatea curatarii ventilatorul; valori: YES(ventilatorul trebuie curatat),
;;							                 NO(ventilatorul nu trebui curatat);
;;
;;	   BATTERY = reprezinta bateria laptopului; valori: REMOVE(bateria este scoasa din laptop), 
;;							    HOT(bateria este supraincalzita),
;;							    NORMAL(bateria nu are probleme);
;;
;;	   CHARGER = reprezinta incarcarea unui alt incarcatorul; valori: YES(s-a incercat incarcarare cu un alt incarcator),
;;						                           NO(nu s-a incercat incarcarare cu un alt incarcator);
;;
;;	   DRIVER = reprezinta driverul de baterie; valori: YES(driverul este actualizat la ultima versiune),
;;							    NO(driverul nu este actualizat la ultima versiune);


(setf *FEATURE-NAMES*
  '(OUTLET POWERCORD POWERBRICK CONNECTION VENT BATTERY CHARGER DRIVER))

(setf *DOMAINS*
  '((YES NO) (TEAR DENT WORN NORMAL) (SMELL WARP NORMAL) (DETACHMENT DAMAGE NORMAL) (YES NO) (REMOVE HOT NORMAL) (YES NO) (YES NO)))

(setf *CATEGORIES*
  '(SERVICE NEGATIVE))


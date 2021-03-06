$PROB MOXONIDINE PK ANALYSIS 
$INPUT      ID VISI XAT2=DROP DGRP DOSE FLAG=DROP ONO=DROP
            XIME=DROP DVO=DROP NEUY SCR AGE SEX NYH=DROP WT DROP ACE
            DIG DIU NUMB=DROP TAD TIME VIDD=DROP CRCL AMT SS II DROP
            CMT=DROP CONO=DROP DV EVID=DROP OVID=DROP
$DATA       mox_simulated.csv IGNORE=@
$ABBREVIATED DERIV2 = NO COMRES = 6
$SUBROUTINES ADVAN2 TRANS1
$PK
;----------IOV--------------------

   KPLAG = 0

   TVCL  = THETA(1)
   TVV   = THETA(2)
   TVKA  = THETA(3)

   CL    = TVCL*EXP(ETA(1))
   V     = TVV*EXP(ETA(2))
   KA    = TVKA*EXP(ETA(3))
   LAG   = THETA(4)
   PHI   = LOG(LAG/(1-LAG))
   ALAG1 = EXP(PHI+KPLAG)/(1+EXP(PHI+KPLAG))
   K     = CL/V
   S2    = V

$ERROR

     IPRED = LOG(.025)
     W     = THETA(5)
     IF(F.GT.0) IPRED = LOG(F)
     IRES  = IPRED-DV
     IWRES = IRES/W
     Y     = IPRED+ERR(1)*W

$THETA (0,27.5) (0,13) (0,0.2) 
$THETA (0,0.077) ; LAG 
$THETA (0,.23) ; W
$OMEGA BLOCK(2) .3 .1 .3
$OMEGA BLOCK(1) .3 ; KA
$SIGMA 1 FIX
$EST MAXEVALS = 9990 PRINT = 10 METHOD=CONDITIONAL
$COVARIANCE PRINT=E




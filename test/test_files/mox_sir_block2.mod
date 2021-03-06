$PROB MOXONIDINE PK ANALYSIS 
$INPUT ID VISI XAT2 DGRP DOSE
       FLAG ONO XIME DVO NEUY
       SCR AGE SEX NYHA WT
       COMP ACE DIG DIU NUMB
       TAD TIME VIDD CLCR AMT
       SS II VID CMT CONO
       DV EVID OVID 
$DATA mox_simulated.csv IGNORE=@
$ABBREVIATED DERIV2 = NO COMRES = 6
$SUBROUTINES ADVAN2 TRANS1
$PK
   TVCL  = THETA(1)
   TVV   = THETA(2)
   TVKA  = THETA(3)
   TVLAG   = THETA(4)

   CL    = TVCL*EXP(ETA(1))
   V     = TVV*EXP(ETA(2))
   KA    = TVKA*EXP(ETA(3))
   LAG   = TVLAG*EXP(0)
   TVPHI   = LOG(LAG/(1-LAG))
   PHI   = TVPHI + (0)
   ALAG1 = EXP(PHI)/(1+EXP(PHI))
   K     = CL/V
   S2    = V

$ERROR

     IPRED = LOG(.025)
     W     = THETA(5)
     IF(F.GT.0) IPRED = LOG(F)
     IRES  = IPRED-DV
     IWRES = IRES/W
     Y     = IPRED+ERR(1)*W

$THETA (0,27.5) (0,13) (0,0.2) (0,.1) (0,.23) 
$OMEGA BLOCK(1) .3
$OMEGA BLOCK(2) 
.3 
0.1 .3
$SIGMA 1 FIX
$EST MAXEVALS = 9990 METH=COND
$COV




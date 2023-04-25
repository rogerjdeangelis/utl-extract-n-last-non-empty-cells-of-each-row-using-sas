%let pgm=utl-extract-n-last-non-empty-cells-of-each-row-using-sas;

Extract N last non-empty cells of each row using SAS

If less that 3 non-missing, just take first 3. (note missings are always last values),
If 3 or more non-missing just shift the first non-missings left into the bit bucket.

Two Solutions
   1. SAS
   2. WPS

github
https://tinyurl.com/mvrw9hvm
https://github.com/rogerjdeangelis/utl-extract-n-last-non-empty-cells-of-each-row-using-sas

stackove4rflow
https://tinyurl.com/4779rkfv
https://stackoverflow.com/questions/76097579/extract-n-last-non-empty-cells-of-each-row-using-sas

Solution by Pete rClemmensen
https://stackoverflow.com/users/4044936/peterclemmensen

data have;
input Order_ID (Fruit1 - Fruit5)(:$);
infile datalines dlm = ',' missover;
cards4;
1234,Banana,Peach,Guava,Apple,,
1235,Orange,Grape,,,,
1236,Pear,Papaya,Apricot,,,
1237,Guava,,,,,
1238,Kiwi,Cherry,Peach,Melon, Lime
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  Obs    ORDER_ID    FRUIT1    FRUIT2    FRUIT3     FRUIT4    FRUIT5                                                    */
/*                                                                                                                        */
/*   1       1234      Banana    Peach     Guava      Apple                                                               */
/*   2       1235      Orange    Grape                                                                                    */
/*   3       1236      Pear      Papaya    Apricot                                                                        */
/*   4       1237      Guava                                                                                              */
/*   5       1238      Kiwi      Cherry    Peach      Melon      Lime                                                     */
/*                                                                                                                        */
/*  RULES (ASSUME MISSINGS ALWAYS OCCUR AFTER NON MISSINGS)                                                               */
/*                                                                                                                        */
/*  Obs    ORDER_ID    FRUIT1    FRUIT2    FRUIT3     FRUIT4    FRUIT5                                                    */
/*                                                                                                                        */
/*                               __last three non missing__                                                               */
/*   1       1234      Banana    Peach     Guava      Apple                                                               */
/*                                                                                                                        */
/*                     __last three non missing__                                                                         */
/*   2       1235      Orange    Grape                                                                                    */
/*                                                                                                                        */
/*                     __last three non missing__                                                                         */
/*   3       1236      Pear      Papaya    Apricot                                                                        */
/*                                                                                                                        */
/*                     __last three non missing__                                                                         */
/*   4       1237      Guava                                                                                              */
/*                                         __last three non missing__                                                     */
/*   5       1238      Kiwi      Cherry    Peach      Melon      Lime                                                     */
/*                                                                                                                        */
/**************************************************************************************************************************/
/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/
/**************************************************************************************************************************/
/*                                                                                                                        */
/*                                                                                                                        */
/*  Up to 40 obs from last table WORK.WANT total obs=5 25APR2023:14:04:51                                                 */
/*                                                                                                                        */
/*  Obs    ORDER_ID    FRUIT1    FRUIT2    FRUIT3                                                                         */
/*                                                                                                                        */
/*   1       1234      Peach     Guava     Apple                                                                          */
/*   2       1235      Orange    Grape                                                                                    */
/*   3       1236      Pear      Papaya    Apricot                                                                        */
/*   4       1237      Guava                                                                                              */
/*   5       1238      Peach     Melon     Lime                                                                           */
/*                                                                                                                        */
/**************************************************************************************************************************/
/*
 ___  __ _ ___   _ __  _ __ ___   ___ ___  ___ ___
/ __|/ _` / __| | `_ \| `__/ _ \ / __/ _ \/ __/ __|
\__ \ (_| \__ \ | |_) | | | (_) | (_|  __/\__ \__ \
|___/\__,_|___/ | .__/|_|  \___/ \___\___||___/___/
                |_|
*/
data want;

  /**************************************************************************************************************************/
  /*  RULES                                                                                                                 */
  /*  Obs    ORDER_ID    FRUIT1    FRUIT2    FRUIT3     FRUIT4    FRUIT5                                                    */
  /*                                                                                                                        */
  /*                               __LAST THREE NON MISSING__                                                               */
  /*   1       1234      Banana    Peach     Guava      Apple                                                               */
  /**************************************************************************************************************************/

   set have;

   array f{*} Fruit:;
   n = dim(f) - cmiss(of f[*]);

   /*---- n=4 non missing for observation 1                               ----*/
   put n=;

   /*---- idx=1 we have 1 more non missing than needed                    ----*/
   idx = (n - 3);
   put idx=;

   if n ge 4 then do i = 1 to n;  /*---- we have 4 so lets start shifting ----*/
   /*---- i + idx = 2 so left shift each by 1 (f[1] into bit bucket)      ----*/
      if i + idx <= 5 then f[i] = f[i + idx];
   end;

   keep Order_ID Fruit1 - Fruit3;

run;quit;

/*
__      ___ __  ___   _ __  _ __ ___   ___ ___  ___ ___
\ \ /\ / / `_ \/ __| | `_ \| `__/ _ \ / __/ _ \/ __/ __|
 \ V  V /| |_) \__ \ | |_) | | | (_) | (_|  __/\__ \__ \
  \_/\_/ | .__/|___/ | .__/|_|  \___/ \___\___||___/___/
         |_|         |_|
*/

%let _pth=%sysfunc(pathname(work));

%utl_submit_wps64('
libname wrk "&_pth";
data want_wps;
   set wrk.have;
   array f{*} Fruit:;
   n = dim(f) - cmiss(of f[*]);
   idx = (n - 3);
   if n ge 4 then do i = 1 to n;
      if i + idx <= 5 then f[i] = f[i + idx];
   end;
   keep Order_ID Fruit1 - Fruit3;
run;quit;
proc print data=want_wps;
run;quit;
');

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/

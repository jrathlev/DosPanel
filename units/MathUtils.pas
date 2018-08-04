(* Delphi Unit
   additional mathematical functions
   ==============================

   - mathematical functions

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - June 1989
   Vers. 2 - May 2015
   last modified:  July 2018
   *)

unit MathUtils;

interface

uses System.SysUtils, System.Math;

const
  Pi180 = Pi/180.0;   (* Grad -> Bogenmaß *)
  Pi200 = Pi/200.0;   (* Neugrad -> Bogenmaß *)

type
  TMean = class (TObject)
    Count : cardinal;
    Sum   : double;
    constructor Create;
    procedure Reset;
    procedure Add(Value : integer); overload;
    procedure Add(Value : double);  overload;
    function Mean: double;
    end;

var
  ln2,ln10,sqrt2 : extended;

function Pwr2 (exp : integer) : int64;

function RMod (x,y : double) : double;

function Lg (x : double) : double;

function Ld (x : double) : double;

function Pwr (x,y : double) : double;

function Kub (x : double) : double;

function Tan (x : double) : double;

function ArcTan1 (x,y : double) : double;

function ArcTan2 (x,y : double) : double;

function ArcTanB (x,y : double) : double;

function RMin (x,y : double) : double;

function RMax (x,y : double) : double;


implementation

{ ------------------------------------------------------------------- }
// Compute mean value
constructor TMean.Create;
begin
  inherited Create;
  Reset;
  end;

procedure TMean.Reset;
begin
  Count:=0; Sum:=0;
  end;

procedure TMean.Add(Value : integer);
begin
  inc(Count); Sum:=Sum+Value;
  end;

procedure TMean.Add(Value : double);
begin
  inc(Count); Sum:=Sum+Value;
  end;

function TMean.Mean: double;
begin
  if Count=0 then Result:=0
  else Result:=Sum/Count;
  end;

{ ------------------------------------------------------------------- }
(* Compute power of 2 as integer *)
function Pwr2 (exp : integer) : int64;
begin
  if exp>63 then exp:=63;
  if exp<0 then exp:=0;
  Result:=1;
  Result:=Result shl exp;
//  for i:=1 to exp do Result:=2*Result;
  end;

(* ----------FUNCTION--RMOD---------------------------------------------
   Divisionsrest bei Fließkommazahlen
*)
function RMod (x,y : double) : double;
begin
  RMod:=x-int(1.000001*x/y)*y;  // Faktor erforderlich wegen Rundungsfehler
  end;

(* ----------FUNCTION--LG-----------------------------------------------
  Dekadischer Logarithmus
*)
function Lg (x : double) : double;
begin
  lg:=ln(x)/ln10;
  end;

(* ----------FUNCTION--Ld-----------------------------------------------
  Dualer Logarithmus
*)
function Ld (x : double) : double;
begin
  Ld:=ln(x)/ln2;
  end;

(* ----------FUNCTION--PWR----------------------------------------------
  allgemeine Exponentialfunktion x ^ y
*)
function Pwr (x,y : double) : double;
begin
  pwr:=exp (y*ln(x));
  end;

(* ----------FUNCTION--KUB----------------------------------------------
   Kubik (x hoch 3) *)
function Kub (x : double) : double;
begin
  Kub:=sqr(x)*x;
  end;

(* ----------FUNCTION--TAN----------------------------------------------
  Tangens
  *)
function Tan (x : double) : double;
var
  c : double;
begin
  c:=cos(x);
  if c<>0.0 then Tan:=sin(x)/c
  else Tan:=Maxdouble;
  end;

(* ----------FUNCTION--ArcTan1------------------------------------------
   ArcTan mit Quadrantenbestimmung, Winkel von 0 .. 360 Grad
   linksweisend gegen Ost (math. pos. Sinn) *)
function ArcTan1 (x,y : double) : double;
var
  z : double;
begin
  if abs(x)<abs(y) then begin
    z:=90.0-ArcTan (x/y)/Pi180;
    if y<0.0 then z:=z+180.0;
    end
  else begin
    if x=0.0 then z:=0.0
    else z:=ArcTan (y/x)/Pi180;
    if x<0.0 then z:=z+180.0;
    end;
  if z<0.0 then z:=z+360.0;
  ArcTan1:=z;
  end;

(* ----------FUNCTION--ArcTan2------------------------------------------
   ArcTan mit Quadrantenbestimmung, Winkel von 0 .. 360 Grad
   rechtsweisend gegen Nord
*)
function ArcTan2 (x,y : double) : double;
var
  z : double;
begin
  if abs(x)<abs(y) then begin
    z:=ArcTan (x/y)/Pi180;
    if y<0.0 then z:=z+180.0
    else if x<0.0 then z:=z+360.0;
    end
  else begin
    if x=0.0 then z:=0.0
    else z:=90.0-ArcTan (y/x)/Pi180;
    if x<0.0 then z:=z+180.0;
    end;
  ArcTan2:=z;
  end;

(* ----------FUNCTION--ArcTan------------------------------------------
   ArcTan mit Quadrantenbestimmung, Winkel in Bogenmaá
   +/- Pi im math. pos. Sinn *)
function ArcTanB (x,y : double) : double;
var
  z : double;
begin
  if abs(x)<abs(y) then begin
    z:=0.5*Pi-ArcTan (x/y);
    if y<0.0 then z:=z+Pi
    else if x<0.0 then z:=z+2*Pi;
    end
  else begin
    if x=0.0 then z:=0.0
    else z:=ArcTan (y/x);
    if x<0.0 then z:=z+Pi;
    end;
  if z<=-Pi then z:=z+2*Pi;
  if z>Pi then z:=z-2*Pi;
  ArcTanB:=z;
  end;

(* ----------FUNCTION--RMIN---------------------------------------------
   Mininum zweier Realzahlen
*)
function rmin (x,y : double) : double;
begin
  if x<y then rmin:=x else rmin:=y;
  end;

(* ----------FUNCTION--RMAX---------------------------------------------
   Maximum zweier Realzahlen
*)
function rmax (x,y : double) : double;
begin
  if x<y then rmax:=y else rmax:=x;
  end;

(* ----------Initialisierung-------------------------------------------- *)
begin
  (* Initialisierung der Konstanten *)
  ln10:=ln(10); ln2:=ln(2); sqrt2:=sqrt(2);
  end.

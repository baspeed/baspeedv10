// ------------------------------------------------------------------------------------------------- //
// -- Código fuente de BASpeed v10                                                                -- //
// -- Codificado originalmente por José Ignacio Legido (usuario de djnacho de bandaancha.eu)      -- //
// -- Creado usando Codetyphon 7.10                                                               -- //
// -- Liberado como código fuente abierto                                                         -- //
// --                                                                                             -- //
// -- Versión final. Liberada con fecha 20/06/2020                                                -- //
// ------------------------------------------------------------------------------------------------- //

unit principal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdHTTP, IdIOHandlerStack, idSSLOpenSSL, TplLabelUnit,
  TplLCDLineUnit, RxVersInfo, BGRALabelFX, DTAnalogGauge, BCButton,
  BGRAFlashProgressBar, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, ComboEx, Spin, Grids, IdComponent, LCLType, pingsend,
  LCLIntf, Menus;

type

  { TForm1 }

  TForm1 = class(TForm) // Objeto ventana principal
    BCButton1: TBCButton; // Botón de comenzar / cancelar test de velocidad
    BCButton2: TBCButton; // Botón de comenzar / cancelar test de ping
    BCButton3: TBCButton; // Botón de comenzar / cancelar test de tracert
    BGRAFlashProgressBar1: TBGRAFlashProgressBar;
    BGRALabelFX1: TBGRALabelFX; // Texto gráfico en pantalla información
    BGRALabelFX2: TBGRALabelFX; // Texto gráfico en pantalla información
    BGRALabelFX3: TBGRALabelFX; // Texto gráfico en pantalla información
    CheckBox1: TCheckBox; // Casilla que indica al test de ping cuando buscar los nombres de nodo
    CheckBox2: TCheckBox; // Casilla que indica al test de tracert cuando buscar los nombres de nodo
    ComboBox1: TComboBox; // Caja de selección de servidor para test de ping
    ComboBox2: TComboBox; // Caja de selección de servidor para test de tracert
    ComboBoxEx1: TComboBoxEx; // Caja de selección de servidor para test de velocidad
    DTAnalogGauge1: TDTAnalogGauge; // Velocímetro analógico del test de velocidad
    Image1: TImage; // Imagen de BASpeed Software en pantalla información
    ImageList1: TImageList; // Lista de imagenes que se usan en el programa
    Label1: TLabel; // Texto
    Label10: TLabel; // Texto
    Label11: TLabel; // Texto
    Label12: TLabel; // Texto
    Label13: TLabel;  // Texto
    Label2: TLabel; // Texto
    Label3: TLabel; // Texto
    Label4: TLabel; // Texto
    Label5: TLabel; // Texto
    Label6: TLabel; // Texto
    Label7: TLabel; // Texto
    Label8: TLabel; // Texto
    Label9: TLabel; // Texto
    PageControl1: TPageControl; // Control de páginas tabuladas
    plLCDLine1: TplLCDLine; // Indicador digital de velocidad
    plLCDLine2: TplLCDLine; // Indicador digital del número de hilos
    plURLLabel1: TplURLLabel; // URL con la dirección del foro de BASpeed
    plURLLabel2: TplURLLabel; // URL con la dirección de bandaancha.eu
    RxVersionInfo1: TRxVersionInfo; // Objeto para obtener la versión del ejecutable
    SpinEdit1: TSpinEdit; // Editor de número de pings a un servidor (test de pings)
    SpinEdit2: TSpinEdit; // Editor de número de saltos máximo (test de tracert)
    StringGrid1: TStringGrid; // Tabla de resultados del test de ping
    StringGrid2: TStringGrid; // Tabla de resultados del test de tracert
    TabSheet1: TTabSheet; // Primera página de tabulación (test de velocidad)
    TabSheet2: TTabSheet; // Segunda página de tabulación (test de ping)
    TabSheet3: TTabSheet; // Tercera página de tabulación (test de tracert)
    TabSheet4: TTabSheet; // Cuarta página de tabulación (información)
    Timer1: TTimer; // Temporizador para mostrar datos del test de velocidad
    procedure AbreBandaAncha(Sender: TObject); // Abre en el navegador por defecto la página del portal bandaancha.eu
    procedure AbreForoOficial(Sender: TObject); // Abre en el navegador por defecto la página del foro oficial de BASpeed
    procedure CambiaNombreServidor(Sender: TObject); // Rutina que le dice al test de ping cuando debe buscar el nombre del nodo
    procedure FormActivate(Sender: TObject); // Rutina al iniciar el programa
    procedure MuestraDatos(Sender: TObject); // Rutina que se activa en cada intervalo del temporizador
    procedure Salir(Sender: TObject);
    procedure TestPing(Sender: TObject); // Rutina que inicia el test de ping
    procedure TestTracert(Sender: TObject); // Rutina que inicia el test de tracert
    procedure TestVelocidad(Sender: TObject); // Rutina que se activa cuando se inicia el test de velocidad
    procedure FalloPing; // Muestra el mensaje de aviso de error si algo falla en el test de ping
    procedure MuestraPing; // Muestra los datos del test de ping
    procedure FinTestPing; // Vuelve a poner la pantalla del test de ping a su estado original
    procedure CancelaTestPing; // Muestra el mensaje de que el usuario ha cancelado el test de ping
    procedure FalloDominioTracert; // Muestra mensaje de error si el dominio no permite realizar ping sobre el
    procedure MuestraTracert; // Muestra los datos de cada salto del tracert
    procedure FinTestTracert; // Vuelve a la pantalla original del test de tracert
  private
    { private declarations }
  public
    { public declarations }
  end;

  TDescarga = class(TThread) // Objeto que realiza una descarga a una URL específica
              url: string; // url de acceso al archivo del test de descarga
              web: TIdHTTP; // objeto HTTP que accede al arhivo de descarga
              mem: TMemoryStream; // buffer de entrada de datos en memoria
              hnd: TIdIOHandlerStack; // Controlador I/O del objeto HTTP
              hnds: TIdSSLIOHandlerSocketOpenSSL; // Controladador I/O bajo capa SSL del objeto HTTP (para test de bandaancha.eu y todos aquellos bajo capa HTTPS)
              tam: uint64; // Tamaño del archivo del test de velocidad
              velocidad: uint64; // Velocidad de la descarga
              ti,tf,tt: int64;  // Tiempo inicial, final y total del test de velocidad
              tpc: uint64; // Tanto por ciento de la descarga completada
              terminado: boolean;
              private
                     procedure CalculaDatos(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64); // Rutina que calcula la velocidad y el tanto por ciento completado en cada descarga
              protected
                       procedure Execute; override; // Rutina de arranque del test de velocidad
  end;

  TEco = class(TThread) // Objeto que lanza un ping a un servidor y recoge los datos del mismo
           servidor: string; // Dominio al que se realiza el test de ping
           radar: TPingSend; // Objeto que contiene todas las rutinas ICMP para realizar el ping
           protected
                    procedure Execute; override;  // Rutina de arranque del test de ping
         end;

  TTracert = class(TThread) // Objeto que permite seguir el camino de los paquetes de información desde el PC hasta el dominio destino
               servidor: string; // Nombre del dominio destino
               radar: TPingSend; // Objetoi que contiene todas las rutinas ICMP para reaslizar pings con un TTL determinado
               ipfinal: string; // La IP final del dominio (necesaria para ir comprobándola con la ip intermedia
               protected
                        procedure Execute; override; // Rutina de arranque del test de tracert
             end;

const
       TAM_BUFFER: longword=512*1024; // 512 KB para buffer de datos
       TIEMPO_ESPERA_DATOS: word=10000; // 10 segundos de espera de datos en buffer de entrada
       TIEMPO_ESPERA_SERVIDOR: word=10000; // 10 segundos de espera para conectar a servidor

var
  Form1: TForm1; // Ventana principal del programa
  tvelocidad: array[1..5] of TDescarga; // Array con los hilos de las 5 descargas simultaneas de cada test de velocidad
  tping: TEco;
  tracert: ttracert;
  testvelocidadiniciado: boolean; // test de velocidad iniciado -> TRUE / finalizado ->FALSE
  vmaxima: uint64; // Velocidad máxima alcanzada en el test de velocidad
  velocidadtotal: uint64; // Velocidad total del test de velocidad calculada como suma de las velocidades de los 5 hilos de ejecución de descarga
  tpctotal: uint64; // Progreso total del test calculado como la suma de los 5 progresos individuales de cada hilo de ejecución y dividido por 5
  hilosactivos: uint64; // Números de hilos de ejecución de descarga simultanea que están funcionando al mimso tiempo
  servidoractivo: boolean; // Marca al programa si un archivo de test de velocidad sigue activo o no
  numtestping: integer; // Número del test de ping actual
  ip: string; // IP del dominio en formato AAA.BBB.CCC.DDD
  tiempoping: integer; // Tiempo total del ping (tiempo que tarda el paquete en ir y volver del servidor del dominio)
  cadenaip: string; // Nombre del servidor asociada a la IP del mismo
  nombreservidor: boolean; // Indica si deben obtenerse los nombres de servidores en test de ping y tracert
  cancelartestvelocidad: boolean; // Indica cuando quiere el usuario cancelar el test de velocidad
  testpingcancelado: boolean; // Indica cuando quiere el usuario cancelar el test de ping
  testpinginiciado: boolean; // Indica cuando está activo el test de ping
  ping1,ping2,ping3: integer; // Valores numéricos de los tres pings del test de tracert
  ip1,ip2,ip3: string; // Valores de tipo cadena de texto que guardan la ip de cada salto en el test de tracert
  numsaltotracert: integer; // Número de salto dentro del test de tracert
  ipintermedia: string; // IP intermedia del nodo actual dentro del test de tracert
  testtracertcancelado: boolean; // Indica cuando quiere el usuario cancelar el test de tracert
  testtracertiniciado: boolean; // Indica si está activo el test de tracert
  px,py: integer; // Posición de la ventana en la pantalla cuando se miniza en la bandeja del sistema

implementation

{$R *.frm}

{ TForm1 }

procedure TForm1.FinTestTracert;

begin
     bcbutton3.ImageIndex:=4; // Imagen original del botón de comenzar test de tracert
     bcbutton3.Caption:='Comenzar test de tracert'; // Pone el texto del botón a su estado original
     if (testtracertcancelado=True) then
        // Si el test ha sido cancelado por el usuario, muestra mensaje de información
        application.MessageBox('El test de tracert ha sido cancelado por el usuario.','Test cancelado por el usuario',MB_OK+MB_ICONINFORMATION);
     testtracertiniciado:=False; // El test de tracert está inactivo
end;

procedure TForm1.MuestraTracert;

begin
     stringgrid2.Cells[1,numsaltotracert-1]:=cadenaip; // Se muestra el nombre del nodo ("---" si no está activa la casilla de averiguar nombre del nodo)
     stringgrid2.Cells[2,numsaltotracert-1]:=ipintermedia; // Se muestra la IP del nodo
     if (ping1=-1) then
        stringgrid2.Cells[3,numsaltotracert-1]:='*' // Si hay timeout muestra * en el tiempo del ping 1
     else
         stringgrid2.Cells[3,numsaltotracert-1]:=inttostr(ping1); // Muestra el valor del ping 1
     if (ping2=-1) then
        stringgrid2.Cells[4,numsaltotracert-1]:='*' // Si hay timeout muestra * en el tiempo del ping 2
     else
         stringgrid2.Cells[4,numsaltotracert-1]:=inttostr(ping2); // Muestra el valor del ping 2
     if (ping3=-1) then
        stringgrid2.Cells[5,numsaltotracert-1]:='*' // Si hay timeout muestra * en el tiempo del ping 3
     else
         stringgrid2.Cells[5,numsaltotracert-1]:=inttostr(ping3); // Muestra el valor del ping 3
end;

procedure TForm1.FalloDominioTracert;

begin
     // Muestra mensaje de error si el dominio no permite paquetes ICMP para realizar pings hasta el
     application.MessageBox(pchar('Se ha producido un fallo al acceder al dominio'+#13+
                            'seleccionado en el test de tracert.'+#13+
                            'Es posible que sea un fallo temporal del dominio'+#13+
                            'en cuyo caso se podrá realizar el test más tarde'+#13+
                            'o bien el dominio no permite realizar test de'+#13+
                            'tracert con lo que no será posible realizar ningún'+#13+
                            'test de tracert hacia ese dominio.'),pchar('Fallo al acceder al dominio en test de tracert'),
                            MB_OK+MB_ICONERROR);
end;

procedure TTracert.Execute;

var
   contador: integer;

begin
     radar:=tpingsend.Create; // Crea el objeto ICMP para poder realizar pings
     radar.PacketSize:=32; // Tamaño del paquete 32 bytes
     radar.Timeout:=2000; // Tiempo de timeout 2000 ms (2 segundos)
     radar.Ping(form1.ComboBox2.Text); // Ping al dominio destino
     if (radar.ReplyError<>ticmperror.IE_NoError) then
        synchronize(@form1.FalloDominioTracert) // Si hay fallo en el ping a dominio destino muestra mensaje de fallo
     else
         begin
              ipfinal:=radar.ReplyFrom; // Obtiene la IP final del dominio destino
              contador:=1; // Inicializa la variable contador a 1
              numsaltotracert:=contador; // Número de salto incial = 1 (punto de inicio -> Módem/Router del usuario)
              repeat
                    if (testtracertcancelado=False) then
                       begin
                            radar.TTL:=contador; // Se inicializa el TTL con la variable contador
                            radar.Ping(form1.combobox2.Text); // Se realiza el ping al dominio destino pero con TTL=contador
                            ping1:=radar.PingTime; // Se recoge el valor del ping
                            ip1:=radar.ReplyFrom; // Se recoge el valor de la IP del nodo
                       end;
                    if (testtracertcancelado=False) then
                       begin
                            radar.Ping(form1.combobox2.Text); // Se realiza el ping al dominio destino pero con TTL=contador
                            ping2:=radar.PingTime; // Se recoge el valor del ping
                            ip2:=radar.ReplyFrom; // Se recoge el valor de la IP del nodo
                       end;
                    if (testtracertcancelado=False) then
                       begin
                            radar.Ping(form1.combobox2.Text); // Se realiza el ping al dominio destino pero con TTL=contador
                            ping3:=radar.PingTime; // Se recoge el valor del ping
                            ip3:=radar.ReplyFrom; // Se recoge el valor de la IP del nodo
                       end;
                    if (ip1<>'') and (ip1<>'0.0.0.0') and (testtracertcancelado=False) then
                       ipintermedia:=ip1 // IP intermedia = ip1 si el nodo devuelve la IP y el test no ha sido cancelado
                    else
                        if (ip2<>'') and (ip2<>'0.0.0.0') and (testtracertcancelado=False) then
                           ipintermedia:=ip2 // IP intermedia = ip2 si el nodo devuelve la IP y el test no ha sido cancelado
                        else
                            if (ip3<>'') and (ip3<>'0.0.0.0') and (testtracertcancelado=False) then
                               ipintermedia:=ip3; // IP intermedia = ip3 si el nodo devuelve la IP y el test no ha sido cancelado
                    if (form1.CheckBox2.Checked=True) and (testtracertcancelado=False) then
                       cadenaip:=radar.Sock.ResolveIPToName(ipintermedia) // Guarda el nombre del nodo si la casilla de averiguar nombre está actia y el test no ha sido cancelado
                    else
                        cadenaip:='---'; // Nombre de nodo = "---" si la casilla no está activa o el test ha sido cancelado
                    inc(contador); // Incrementa el contador de salto dentro del tracert
                    inc(numsaltotracert); // Incrementa el número de salto del tracert
                    if (testtracertcancelado=False) then
                       synchronize(@form1.MuestraTracert); // Muestra los datos del salto actual del tracert
              until (ipintermedia=ipfinal) or (contador>form1.SpinEdit2.Value) or (testtracertcancelado=True); // Repetir hasta que se llegue al dominio destino, o que se supere el número de saltos máximo o se cancele el test de tracert
              synchronize(@form1.FinTestTracert); // Recupera el estado original del test de tracert para poder iniciar otro test
         end;
end;

procedure TForm1.FinTestPing;

begin
     BCButton2.ImageIndex:=3; // Se escoge la imagen original para empezar el test de ping
     BCButton2.Caption:='Comenzar test de ping'; // Se cambia el texto del botón
     combobox1.Enabled:=True; // Se activa la lista de dominios
     spinedit1.Enabled:=True; // Se activa el contador de saltos
     checkbox1.Enabled:=True; // Se activa el check para nombres de nodo
     testpinginiciado:=False; // Se actualizan las variables que informan del estado del test de ping
     testpingcancelado:=False;
end;

procedure TForm1.FalloPing;

begin
     // Muestra el mensaje de error del test de ping en pantalla
     Application.MessageBox(pchar('Se ha producido un fallo al intentar medir el ping'+#13+
                                  'del servidor. Compruebe que el dominio está bien'#13+
                                  'escrito y que el dominio existe, está activo y no está'+#13+
                                  'filtrado contra ataques de paquetes ICMP.'),pchar('Error en test de ping'),
                                  MB_OK+MB_ICONERROR);
end;

procedure TForm1.CancelaTestPing;

begin
     // Muestra el mensaje de test cancelado por el usuario
     Application.MessageBox(pchar('Test de ping cancelado por el usuario.'),pchar('Test de ping cancelado'),MB_OK+MB_ICONERROR);
end;

procedure TForm1.MuestraPing;

begin
     if (nombreservidor=True) then // Si está activa esa variable
        begin
             if (cadenaip='') then
                stringgrid1.Cells[1,numtestping]:='No Responde'
             else
                 stringgrid1.Cells[1,numtestping]:=cadenaip // Muestra el nombre del servidor
        end
     else
         stringgrid1.Cells[1,numtestping]:='---'; // Si no no escribe nada
     stringgrid1.Cells[2,numtestping]:=ip; // Muestra la IP del dominio
     if (tiempoping=-1) then
        stringgrid1.Cells[3,numtestping]:='*'
     else
         stringgrid1.Cells[3,numtestping]:=inttostr(tiempoping); // Muestra el tiempo del ping
end;

procedure TEco.Execute;

var
   contador: integer;

begin
     radar:=TPingSend.Create; // Crea el objeto ICMP que permite el test de ping
     radar.Timeout:=2000; // Inicializa el máximo tiempo de espera hasta que se produzca un error por falta de respuesta
     radar.PacketSize:=32; // Tamaño del paquete de datos a mandar al dominio
     numtestping:=1; // Inicializa el número del test de ping inicial
     for contador:=1 to form1.SpinEdit1.Value do // Desde 1 hasta número de veces indicado que se quiere realzar el test de ping
         begin
              if (testpingcancelado=False) then  // Si no se ha cancelado el test dfe ping
                 begin
                      radar.Ping(form1.ComboBox1.Text); // Realiza el ping al dominio
                      if (radar.ReplyError<>ticmperror.IE_NoError) and (radar.PingTime<>-1) then // Si hay algún error en el test de ping
                         begin
                              synchronize(@Form1.FalloPing); // Muestra fallo en pantalla
                              break; // Sal del bucle y finaliza el hilo de ejecución
                         end
                      else
                          begin
                               ip:=radar.ReplyFrom; // Recoge la IP del dominio
                               if (nombreservidor=True) then
                                  cadenaip:=radar.Sock.ResolveIPToName(ip); // Averigua el nombre real del servidor a través de su IP
                               tiempoping:=radar.PingTime; // Recoge el tiempo del ping
                               synchronize(@Form1.MuestraPing); // Muestra los datos por pantalla
                               inc(numtestping); // Incrementa el número del test de ping
                          end;
                 end
              else
                  begin
                       synchronize(@form1.CancelaTestPing); // Muestra mensaje de test cancelado y termina test de ping
                       break;
                  end;
         end;
     synchronize(@Form1.FinTestPing); // Vuelve todo a su estado original
end;

procedure TDescarga.CalculaDatos(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);

begin
     if (AWorkMode=TworkMode.wmRead) and (cancelartestvelocidad=False) then
        begin
             mem.Seek(0,0); // Mover el puntero de memoria al inicio del buffer
             tf:=gettickcount64; // obtiene el tiempo transcurrido actual
             tt:=tf-ti; // calcula la diferencia de tiempos entre el inicio del test y ahora mismo
             velocidad:=(AWorkCount div tt) * 8; // Calcula la velocidad en Kbits/s
             tpc:=(AworkCount*100) div tam; // Calcula el tanto por ciento completado
        end
     else
         if (AWorkMode=TWorkMode.wmRead) and (cancelartestvelocidad=True) then
            begin
                 web.Disconnect; // Si se cancela el test de velocidad, desconecta del servidor para terminar el test de velocidad
            end;
end;

procedure TDescarga.Execute;

begin
     terminado:=False;
     mem:=tmemorystream.Create; // Se crea el buffer de entrada de datos
     mem.SetSize(TAM_BUFFER); // 512 KB de buffer de entrada de datos
     web:=tidhttp.Create; // Se crea el objeto de acceso al archivo HTTP
     if (form1.ComboBoxEx1.ItemIndex<>1) then
        begin
             hnd:=tidiohandlerstack.Create(web); // Crea el controlador del objeto HTTP
             hnd.RecvBufferSize:=TAM_BUFFER; // Inicializa tamaño buffer recepción datos
             hnd.ConnectTimeout:=TIEMPO_ESPERA_SERVIDOR; // Tiempo de espera hasta conexión con servidor
             hnd.ConnectTimeout:=TIEMPO_ESPERA_DATOS; // Tiempo de espera hasta recepción de datos en buffer de recepción
             web.IOHandler:=hnd; // Le dice al objeto HTTP cual es su controlador
             web.OnWork:=@CalculaDatos; // Le dice al objeto HTTP cual es la rutina que debe lanzar cada vez que se llena el buffer de recepción
             inc(hilosactivos);
             try
                web.Get(url,mem); // Descargar archivo HTTP designado por url al buffer mem
             except
                   on Exception do
                                begin
                                     terminado:=true; // Si ocurre cualquier error no hacer nada
                                     velocidad:=0; // Se pone la velocidad de descarga del hilo a 0
                                     dec(hilosactivos);
                                end;
             end;
        end
     else
         begin
             hnds:=TIdSSLIOHandlerSocketOpenSSL.Create(web); // Crea el controlador del objeto HTTP
             hnds.RecvBufferSize:=TAM_BUFFER; // Inicializa tamaño buffer recepción datos
             hnds.ConnectTimeout:=TIEMPO_ESPERA_SERVIDOR; // Tiempo de espera hasta conexión con servidor
             hnds.ConnectTimeout:=TIEMPO_ESPERA_DATOS; // Tiempo de espera hasta recepción de datos en buffer de recepción
             web.IOHandler:=hnds; // Le dice al objeto HTTP cual es su controlador
             web.OnWork:=@CalculaDatos; // Le dice al objeto HTTP cual es la rutina que debe lanzar cada vez que se llena el buffer de recepción
             inc(hilosactivos);
             try
                web.Get(url,mem); // Descargar archivo HTTP designado por url al buffer mem
             except
                   on Exception do
                                begin
                                     terminado:=true; // Si ocurre cualquier error no hacer nada
                                     velocidad:=0; // Se pone la velocidad de descarga del hilo a 0
                                     dec(hilosactivos);
                                end;
             end;
        end;
     dec(hilosactivos);
     velocidad:=0; // Se pone la velocidad de descarga del hilo a 0
     mem.Free; // Liberar el buffer de entrada de datos
     hnd.Free; // Liberar controlador del objeto HTTP
     web.Free; // Liberar objeto de acceso al archivo HTTP
     terminado:=True; // Pone a True la variable que indica que la descarga ha finalizado
end;

procedure TForm1.FormActivate(Sender: TObject);

var
   dia,mes,anio: word;
   fecha: tdatetime;
   {cadanio,cadmes,caddia: string;}

begin
     testvelocidadiniciado:=False; // Variable que indica cuando se ha iniciado un test de velocidad
     fileage('BASpeedv10-x32.exe',fecha,true); // Se recoge la fecha de creación del archivo ejecutable
     decodedate(fecha,anio,mes,dia); // se decodifica la fecha en campos de año, mes y dia
     {if (mes<10) then                // Rutina para poner el mes con un 0 delante si es menor de 10
        cadmes:='0'+inttostr(mes)
     else
         cadmes:=inttostr(mes);
     if (dia<10) then                // Rutina para poner el dia con un 0 delante si es menor de 10
        caddia:='0'+inttostr(dia)
     else
         caddia:=inttostr(dia);
     cadanio:=inttostr(anio);}
     bgralabelfx3.Caption:='Versión: '+rxversioninfo1.FileVersion; // Información de versión del programa
end;

procedure TForm1.CambiaNombreServidor(Sender: TObject);
begin
     if (checkbox1.Checked=True) then // Si la casilla está activa en el test de ping
        nombreservidor:=True // Activa la variable para que se obtenga el nombre del servidor
     else
         nombreservidor:=False; // Desactiva la variable para que sólo se obtenga la IP y el tiempo
end;

procedure TForm1.AbreForoOficial(Sender: TObject);
begin
     OpenURL('http://bandaancha.eu/foros/comunidad/herramientas/baspeed');
end;

procedure TForm1.AbreBandaAncha(Sender: TObject);
begin
     OpenURL('http://bandaancha.eu'); // Abre en el navegador por defecto la página de bandaancha.eu
end;

procedure TForm1.MuestraDatos(Sender: TObject);

var
   contador: word; // Contador de hilos de descarga simultanea

begin
     velocidadtotal:=0; // Velocidad media total
     tpctotal:=0; // Tanto por ciento total
     for contador:=1 to 5 do
         begin
              velocidadtotal:=velocidadtotal+tvelocidad[contador].velocidad; // La velocidad total es la suma de las velocidades de todos los hilos
              tpctotal:=tpctotal+tvelocidad[contador].tpc; // El tanto por ciento total es la suma de todos los tanto por ciento de cada hilo
         end;
     tpctotal:=tpctotal div 5; // Se divide el tanto por ciento total entre 5 para averiguar el tanto por ciento total entre 0 y 100
     if ((velocidadtotal div 1000)>DTAnalogGauge1.ScaleSettings.Maximum) then  // Si se supera la velocidad máxima del velocímetro
        DTAnalogGauge1.Position:=DTAnalogGauge1.ScaleSettings.Maximum  // La velocidad máxima es la máxima del velocímetro
     else
         DTAnalogGauge1.Position:=(velocidadtotal div 1000); // En caso contrario es la velocidad medida dividida por 1000 para averiguar la velocidad en MBit/s
     plLCDLine1.Text:=inttostr(velocidadtotal)+'Kbps ('+floattostrf(velocidadtotal/1000,fffixed,7,2)+' Mbps)'; // Se pone la velocidad en el cuadro digital
     BGRAFlashProgressBar1.Value:=tpctotal; // Se actualiza el progreso del test de velocidad (tanto por ciento completado)
     label13.Caption:=inttostr(tpctotal)+'%';
     plLCDLine2.Text:=inttostr(hilosactivos); // Se actualiza el número de hilos activos
     if (velocidadtotal>vmaxima) then
        vmaxima:=velocidadtotal; // Se actualiza el valor de la velocidad máxima si procede
     if (tvelocidad[1].terminado=true) and (tvelocidad[2].terminado=true) and (tvelocidad[3].terminado=true) and (tvelocidad[4].terminado=true) and (tvelocidad[5].terminado=true) then
        begin
             for contador:=1 to 5 do
                 begin
                      tvelocidad[contador].Free; // Si han acabado todos los hilos de descarga entonces liberar la memoria de los mismos
                 end;
             BCButton1.ImageIndex:=2; // Volver el botón a su estado original
             BCButton1.Caption:='Comenzar test de velocidad';
             Timer1.Enabled:=False; // Deshabilitar el temporizador para mostrar la información
             testvelocidadiniciado:=False; // El test de velocidad está acabado
             Application.MessageBox(pchar('La velocidad máxima alcanzada en el test de velocidad'+#13+
                                   'ha sido de '+inttostr(vmaxima)+' Kbps ('+floattostrf(vmaxima/1000,fffixed,10,2)+' Mbps)'),pchar('Test de velocidad finalizado'),
                                   MB_OK+MB_ICONINFORMATION); // Muestra la información de la velocidad máxima al acabar el test de velocidad
        end;
end;

procedure TForm1.Salir(Sender: TObject);
begin
     Application.Terminate; // Termina la ejecución de la aplicación y cierra la ventana de la misma
end;

procedure TForm1.TestPing(Sender: TObject);

begin
     if (testpinginiciado=False) then
        begin
             testpingcancelado:=False; // Inicializa variables, imagen y texto del botón de comenzar test de ping
             testpinginiciado:=True;
             BCButton2.ImageIndex:=5;
             BCButton2.Caption:='Cancelar test de ping';
             combobox1.Enabled:=False;
             spinedit1.Enabled:=False;
             checkbox1.Enabled:=False;
             stringgrid1.Clean; // Limpia la tabla de datos del test de ping
             tping:=TEco.Create(True); // Crea el hilo de ejecución para el test de ping
             tping.FreeOnTerminate:=True; // Libera la memoria cuando finalize el test de ping
             tping.servidor:=combobox1.Text; // Inicializa el dominio al que se debe medir el tiempo de ping
             tping.Start; // Comienza la ejecución del test de ping
        end
     else
         begin
              testpingcancelado:=True;
         end;
end;

procedure TForm1.TestTracert(Sender: TObject);
begin
     // Si el test de tracert no estaba activo
     if (testtracertiniciado=False) then
        begin
             stringgrid2.Clean; // Limpia la lista de datos del test de tracert
             bcbutton3.ImageIndex:=5; // Imagen del test de tracert a cancelar
             bcbutton3.Caption:='Cancelar test de tracert'; // Cambia texto del botón del test
             testtracertcancelado:=False; // Test de tracert cancelado? NO
             testtracertiniciado:=True; // Test de tracert iniciado? SI
             tracert:=ttracert.Create(true); // Crea el hilo de ejecución del test de tracert en estado de espera
             tracert.FreeOnTerminate:=True; // Libera la memoria del hilo de ejecución cuando este haya terminado
             tracert.Start; // Inicia el hilo de ejecución del test de tracert
        end
     else
         begin
              testtracertcancelado:=True; // Test de tracert cancelado? SI
         end;
end;

procedure TForm1.TestVelocidad(Sender: TObject);

var
   contador: word; // Contador de hilos de descarga simultanea
   web: tidhttp; // Objeto que permite acceder a recursos HTTP

begin
     cancelartestvelocidad:=False;
     if (testvelocidadiniciado=False) then  // Si el test de velocidad no se ha iniciado
        begin
             hilosactivos:=0; // Numero de hilos activos = 0
             vmaxima:=0; // Velocidad máxima alcanzada = 0
             for contador:=1 to 5 do // Actualiza el archivo del test de velocidad según la elección del usuario
                 begin
                      tvelocidad[contador]:=TDescarga.Create(true); // Crea un hilo de ejecución
                      tvelocidad[contador].FreeOnTerminate:=False;  // No se libera la memoria automáticamente
                      case comboboxex1.ItemIndex of
                           0 : tvelocidad[contador].url:='http://speedtestmadrid2.vodafone.es/speedtest/random4000x4000.jpg';
                           1 : tvelocidad[contador].url:='https://testvelocidad.eu/speed-test/download.bin';
                           2 : tvelocidad[contador].url:='http://speedtest.tele2.net/100MB.zip';
                           3 : tvelocidad[contador].url:='http://download.microsoft.com/download/0/A/F/0AFB5316-3062-494A-AB78-7FB0D4461357/Windows_Win7SP1.7601.17514.101119-1850.IA64FRE.Symbols.msi';
                           4 : tvelocidad[contador].url:='http://speedtest.ams01.softlayer.com/downloads/test100.zip';
                           5 : tvelocidad[contador].url:='http://speedtest.london.linode.com/100MB-london.bin';
                      end;
                      servidoractivo:=True; // Comprueba que el archivo está activo leyendo la cabecera HTTP del archivo
                      try
                         web:=tidhttp.Create; // Crea el objeto HTTP
                         web.Head(tvelocidad[contador].url); // Lee la cabecera HTTP del archivo URL
                      except
                           On Exception do
                                 servidoractivo:=False; // Si el archivo no está activo se actualiza la variable servidoractivo a False
                      end;
                      if (servidoractivo=True) then // Si el archivo está activo, inicia los 5 hilos de ejecución simultanea de descarga
                         begin
                              tvelocidad[contador].tam:=web.Response.ContentLength; // Actualiza el tamaño del archivo
                              web.Free; // Libera la memoria del objeto HTTP
                              tvelocidad[contador].ti:=gettickcount64; // Recoje la medida del tiempo actual en Ticks
                              tvelocidad[contador].Start; // Inicia el hilo de ejecución de descarga
                         end;
                 end;
             if (servidoractivo=True) then // Si el archivo está activo
                begin
                     Timer1.Enabled:=True; // Inicia temporizador para mostrar datos
                     BCButton1.ImageIndex:=5; // Actualiza imagen del botón
                     BCButton1.Caption:='Cancelar test de velocidad'; // Cambia texto del botón
                     testvelocidadiniciado:=True; // Actualiza la variable que indica que el test ha sido iniciado
                end
             else
                 begin
                      // Muestra un mensaje de error si el archivo no está activo
                      Application.MessageBox(pchar('Ha ocurrido un fallo al acceder al archivo'+#13+
                                             'del test de velocidad. Avise cuanto antes a'+#13+
                                             'djnacho en el foro oficial de BASpeed para'#13+
                                             'que revise ese test de velocidad en concreto'+#13+
                                             'y lo cambie si es necesario.'),pchar('Error en test de velocidad'),
                                             MB_OK+MB_ICONERROR);
                 end;
        end
     else
         // Si el test ya se había iniciado y está en ejecución y se pulsa el botón cancelar test
         begin
              cancelartestvelocidad:=True;
              testvelocidadiniciado:=False; // Se actualiza la variable que indica que el test se está ejecutando
              BCButton1.ImageIndex:=2; // Cambia imagen del botón
              BCButton1.Caption:='Comenzar test de velocidad'; // Cambia texto del botón
              for contador:=1 to 5 do
                  tvelocidad[contador].Free; // Libera la memoria de todos los hilos de ejecución
              Timer1.Enabled:=False; // Detiene el temporizador que muestra los datos del test de velocidad
              plLCDLine2.Text:=inttostr(hilosactivos); // Actualiza el número de hilos activos
              Application.MessageBox(pchar('La velocidad máxima alcanzada en el test de velocidad'+#13+
                                     'ha sido de '+inttostr(vmaxima)+' Kbps ('+floattostrf(vmaxima/1000,fffixed,10,2)+' Mbps)'),pchar('Test de velocidad finalizado'),
                                     MB_OK+MB_ICONINFORMATION); // Muestra la velocidad máxima alacanzada en el test de velocidad
         end;
end;

end.
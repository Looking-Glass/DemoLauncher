import processing.serial.*;

Serial port;

void initializeSerialController()
{
  try {
    port=new Serial(this, Serial.list()[Serial.list().length-1], 115200);
    port.bufferUntil('\n');
  }
  catch(Exception e)
  {
    println(e);
  }
}

void serialEvent(Serial p) { 
  String sep=StringEscapeUtils.escapeJava(File.separator);
  String appNames=getAppNames();
  //  appNames+=",stop,";
  String[] apps=appNames.split(",");
  String str = p.readString();
  int num=int(str.trim());
  if (num==24)
    closeProgram(runningProgram);
  else if (num<apps.length)
    runProgram(apps[num]);
} 
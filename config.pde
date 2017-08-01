import java.nio.file.Files;

String computerName="";
String rootDir="";
StringDict shortcuts;

boolean loadConfig()
{
  boolean success=true;
  shortcuts=new StringDict();
  String[] lines=loadStrings(dataPath("config.txt"));
  try {
    computerName=lines[0];
    rootDir=lines[1];
    for (int i=2; i<lines.length; i++)
    {
      String[] parts=lines[i].split(",");
      shortcuts.set(parts[0], parts[1]);
    }
    println(computerName);
    println(rootDir);
  } 
  catch(Exception e)
  {
    println(e);
    success=false;
    computerName="";
    rootDir="";
  }
  if (lines==null)
    success=false;
  if (!(new File(rootDir).exists()))
    success=false;
  if (success==false)
    mode="computerName";
  return success;
}
void writeConfig()
{
  PrintWriter output=createWriter(dataPath("config.txt"));
  output.println(computerName);
  output.println(rootDir);
  String [] keys=shortcuts.keyArray();
  String [] values=shortcuts.valueArray();
  for (int i=0; i<keys.length; i++)
    output.println(keys[i]+","+values[i]);
  output.flush();
  output.close();
}
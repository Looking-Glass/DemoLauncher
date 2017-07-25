String computerName="";
String rootDir="";

boolean loadConfig()
{
  boolean success=true;
  String[] lines=loadStrings(dataPath("config.txt"));
  try {
    computerName=lines[0];
    rootDir=lines[1];
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
  if (success==false)
    mode="computerName";
  return success;
}
void writeConfig()
{
  PrintWriter output=createWriter(dataPath("config.txt"));
  output.println(computerName);
  output.println(rootDir);
  output.flush();
  output.close();
  
}
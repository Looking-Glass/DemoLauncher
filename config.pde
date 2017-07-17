String computerName;
String rootDir;

void loadConfig()
{
  String[] lines=loadStrings(dataPath("config.txt"));
  computerName=lines[0];
  rootDir=lines[1];
  println(computerName);
  println(rootDir);
}
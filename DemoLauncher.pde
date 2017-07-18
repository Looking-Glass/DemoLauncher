import http.requests.*;

int lastUpdated=0;
int interval=1000;
StringList processes=new StringList();
StringList availablePrograms=new StringList();

void setup() {
  size(100, 100);
  loadConfig();
  println("existing apps: "+getExistingApps());
  println("existing app names: "+getAppNames());
}

void draw()
{
  background(0);
  if (millis()-lastUpdated>interval)
    update();
}

void update()
{
  PostRequest post = new PostRequest("http://launcher.lookingglassfactory.com/update/");
  post.addData("name", computerName);
  post.addData("existingApps", getAppNames());
  post.send();
  respondToAction(post.getContent());
  lastUpdated=millis();
}

void respondToAction(String action)
{
  if (action.length()>0)
  {
    println("responding to: "+action);
    String[] parts=action.split(",");
    String command=trim(parts[0]);
    String parameter=trim(parts[1]);
    println(command);
    if (command.equals("run"))
      runProgram(parameter);
    if (command.equals("stop"))
      closeProgram(runningProgram);
  }
}
void runProgram(String programName)
{
  if (!programName.equals(runningProgram))
  {
    if (runningProgram!="")
    {
      println("closing program "+runningProgram);
      closeProgram(runningProgram);
    }
    StringList apps=getAllFiles(rootDir, "exe");    
    for (int i=0; i<apps.size(); i++)
    {
      if (apps.get(i).indexOf(programName)!=-1)
      {
        println("running "+apps.get(i));
        launch(apps.get(i));
        runningProgram=programName;
        break;
      }
    }
  }
}
String getExistingApps()
{
  StringList apps=getAllFiles(rootDir, "exe");
  String val="";
  for (int i=0; i<apps.size(); i++)
  {    
    val+=apps.get(i);
    if (i<apps.size()-1)
      val+=",";
  }
  return val;
}

String getAppNames()
{
  String sep=StringEscapeUtils.escapeJava(File.separator);
  StringList apps=getAllFiles(rootDir, "exe");
  String val="";
  for (int i=0; i<apps.size(); i++)
  {    
    String appName=apps.get(i);    
    String[] parts=appName.split(sep);
    try {
      val+=parts[parts.length-1];
      if (i<apps.size()-1)
        val+=",";
    }
    catch(Exception e) {
    }
  }
  return val;
}
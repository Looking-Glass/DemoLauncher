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
  println("responding to: "+action);
  if(action.length()>0)
  {
    String[] parts=action.split(",");
    String command=parts[0];
    String parameter=parts[1];
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
  StringList apps=getAllFiles(rootDir, "exe");
  String val="";
  for (int i=0; i<apps.size(); i++)
  {    
    String appName=apps.get(i);    
    String[] parts=appName.split(File.separator);
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
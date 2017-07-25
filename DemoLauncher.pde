import http.requests.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

Robot robot;
int lastUpdated=0;
int interval=1000;
StringList processes=new StringList();
StringList availablePrograms=new StringList();
boolean configured;
String mode="computerName";
boolean updating=false;
String serverResponse="";
void setup() {
  size(800, 800);
  runConfig();
  //Let's get a Robot...
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
    exit();
  }
  textSize(24);
}

void runConfig()
{
  configured=loadConfig(); //if we don't have an existing configuration file, go through the config and create one
  if (configured)
  {
    println("existing apps: "+getExistingApps());
    println("existing app names: "+getAppNames());
  }
}

void draw()
{
  background(0);
  if (!configured)
  {
    if (mode=="computerName")
    {
      fill(255);
      String msg="enter a unique name for this computer, then press enter";
      text(msg, (width-textWidth(msg))/2, height/3);
      String nameString=computerName;
      if ((millis()/250)%2==0)
        nameString+="|";
      stroke(255);
      fill(100, 150, 0);
      rect((width-300)/2, (height/2)-30, 300, 30+10);
      fill(0);
      text(nameString, (width-300)/2+5, height/2);
    }
    if (mode=="directory")
    {
      fill(255);
      String msg="Select a directory with all your executables inside";
      text(msg, (width-textWidth(msg))/2, height/3);
      mode="folder dialog";
      selectFolder("Select a directory with all your executables inside:", "folderSelected");
    }
    if (mode=="folder failed")  //maybe print an error message here late
      mode="directory";
  } else
  {
    if (millis()-lastUpdated>interval)
      serverResponse=update();
    fill(255, 0, 0);
    if (updating)
      ellipse(width-50, 50, 10, 10);
    fill(255);
    text("computer name: "+computerName, 20, 100);
    text("demo directory: "+rootDir, 20, 130);
    String str="server response: "+serverResponse;
    text(str, 100, height*3/4);
    str="running program: "+runningProgram;
    text(str, 100, height*3/4+30);
    text("press 'c' to reconfigure", 100,height-30);
  }
}

void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    mode="directory";
  } else {
    mode="folder failed";
    println("User selected " + selection.getAbsolutePath());
    rootDir=selection.getAbsolutePath();
    writeConfig();
    runConfig();
    configured=true;
  }
}

void keyPressed()
{
  if (!configured)
  {
    if (mode=="computerName")
    {
      if ((keyCode==DELETE)||(keyCode==BACKSPACE))
      {
        if (computerName.length()>0)
          computerName=computerName.substring(0, computerName.length()-1);
      } else if ((keyCode==ENTER)||(keyCode==RETURN))
        mode="directory"  ;
      else
        computerName+=key;
    }
  } else
  {
    if (key=='c')
    {
      configured=false;
      mode="computerName";
    }
  }
}

String update()
{
  PostRequest post = new PostRequest("http://launcher.lookingglassfactory.com/update/");
  post.addData("name", computerName);
  post.addData("existingApps", getAppNames());
  post.send();
  String serverResponse=post.getContent();
  respondToAction(serverResponse);
  lastUpdated=millis();
  updating=!updating;
  return(serverResponse);
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
        delay(5000);
        //tap enter to get past the resolution popup, if it's there
        robot.keyPress(KeyEvent.VK_ENTER);
        robot.keyRelease(KeyEvent.VK_ENTER);
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
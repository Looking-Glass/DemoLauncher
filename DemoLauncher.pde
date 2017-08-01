import controlP5.*;  
import http.requests.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

ControlP5 cp5;  
Group buttons;
Robot robot;
int lastUpdated=0;
int interval=1000;
StringList processes=new StringList();
StringList availablePrograms=new StringList();
boolean configured;
String mode="computerName";
boolean updating=false;
String serverResponse="";
int buttonWidth=700;
int buttonHeight=100;
int buttonSpacing=20;
int buttonColumns=3;
int buttonOffset=200;
ControlFont font;
boolean settingUp;

void setup() {
  size(displayWidth, displayHeight);
  cp5 = new ControlP5(this);
  font = new ControlFont(createFont("Times", 18));
  runConfig();
  //Let's get a Robot...
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
    exit();
  }
  initializeSerialController();
  textSize(24);
}

void runConfig()
{
  configured=loadConfig(); //if we don't have an existing configuration file, go through the config and create one
  if (configured)
  {
    println("existing apps: "+getExistingApps());
    println("existing app names: "+getAppNames());
    setupUI();
  }
}

void draw()
{
  background(0);
  if (!configured)
  {
    cp5.hide();
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
    cp5.show();
    if (millis()-lastUpdated>interval)
      serverResponse=update();
    fill(255, 0, 0);
    if (updating)
      ellipse(width-50, 50, 10, 10);
    fill(255);
    text("computer name: "+computerName, 20, 100);
    text("demo directory: "+rootDir, 20, 130);
    String str="server response: "+serverResponse;
    text(str, 100, height-90);
    str="running program: "+runningProgram;
    text(str, 100, height-60);
    text("press 'c' to reconfigure", 100, height-30);
  }
}

void setupUI()
{
  settingUp=true;
  cp5.remove("buttons");
  buttons= cp5.addGroup("buttons");      
  int row, col;
  String sep=StringEscapeUtils.escapeJava(File.separator);
  String appNames=getAppNames();
  //  appNames+=",stop,";
  String[] apps=appNames.split(",");
  for (int i=0; i<apps.length; i++)
    addButton(i, apps[i]);
  addButton(apps.length, "stop programs");
  settingUp=false;
}

void addButton(int i, String name)
{
  int margin=(width-(buttonColumns*buttonWidth + buttonColumns-1*buttonSpacing))/2;
  int row, col;
  println("creating button for "+name);
  row=i/buttonColumns;
  col=i%buttonColumns;
  cp5.addButton(name)
    .setValue(i)
    .setPosition(margin+col*(buttonWidth+buttonSpacing), row*(buttonHeight+buttonSpacing) + buttonOffset  )
    .setSize(buttonWidth, buttonHeight)
    .setGroup(buttons)
    .setFont(font);
  ;
}

public void controlEvent(ControlEvent theEvent) {
  if (!settingUp) {
    String button=theEvent.getController().getName();
    println("event for button "+button);
    if (button.equals("stop programs"))
      closeProgram(runningProgram);
    else
      runProgram(button);
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
    } else
    {
      String str=""+key;
      if (shortcuts.hasKey(str))
      {
        println(shortcuts.get(str));
        String [] apps=getAppNames().split(",");
        for (int i=0; i<apps.length; i++)
          if (apps[i].toLowerCase().contains(shortcuts.get(str).toLowerCase()))
          {
            println(apps[i]);
            runProgram(apps[i]);
          }
        //        str1.toLowerCase().contains(str2.toLowerCase())
      }
    }
  }
}

String update()
{
  String serverResponse="";
  try {
    PostRequest post = new PostRequest("http://launcher.lookingglassfactory.com/update/");
    post.addData("name", computerName);
    post.addData("existingApps", getAppNames());
    post.send();
    serverResponse=post.getContent();
    respondToAction(serverResponse);
    lastUpdated=millis();
    updating=!updating;
  }
  catch(Exception e) {
  }
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
        delay(1500);
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
import java.io.InputStreamReader;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.WildcardFileFilter;
import java.util.*;
import java.util.Properties;

String runningProgram="";

void getProcesses()
{
  processes.clear();
  try {
    String line;
    //mac
    //Process p = Runtime.getRuntime().exec("ps -e");
    Process p = Runtime.getRuntime().exec
      (System.getenv("windir") +"\\system32\\"+"tasklist.exe");
    BufferedReader input =
      new BufferedReader(new InputStreamReader(p.getInputStream()));
    while ((line = input.readLine()) != null) {
      processes.append(line);
    }
    input.close();
  } 
  catch (Exception err) {
    err.printStackTrace();
  }
  lastUpdated=millis();
}

void closeProgram(String programName)
{
  try {
    Runtime rt = Runtime.getRuntime();
    rt.exec("taskkill /F /IM "+programName);
  }
  catch(Exception e)
  {
    println("uh oh");
    println(e);
  }
}

StringList getAllFiles(String directoryName, String extension)
{
  File directory = new File(directoryName);
  String[] extensions={extension};
  Collection x= FileUtils.listFiles(directory, extensions, true);
  StringList files=new StringList();
  for(int i=0;i<x.size();i++)
  {
    File f=(File)x.toArray()[i];
    files.append(f.getAbsolutePath());
  }
  return files;
}
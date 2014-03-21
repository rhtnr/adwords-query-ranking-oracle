import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.sql.*;





public class adwords {
	
	public static void main(String args[])
	{
		System.out.println("-------- Oracle JDBC Connection Testing ------");
		 
		try {
 
			Class.forName("oracle.jdbc.driver.OracleDriver");
 
		} catch (ClassNotFoundException e) {
 
			System.out.println("Where is your Oracle JDBC Driver?");
			e.printStackTrace();
			return;
 
		}
 
		System.out.println("Oracle JDBC Driver Registered!");
 
		Connection connection = null;
 
		try {
			
			
			FileReader fileReader = new FileReader("system.in");
			BufferedReader bufferedReader = new BufferedReader(fileReader);
			String line = bufferedReader.readLine();
			String userpass[] = line.split("=");
			String user = userpass[1].trim();
			line = bufferedReader.readLine();
			userpass = line.split("=");
			String pass = userpass[1].trim();
			
			int t1 = -1, t2 = -1, t3 = -1, t4 = -1, t5 = -1, t6 = -1;
			
			while((line = bufferedReader.readLine())!=null)
			{
				if(line.indexOf("TASK1")!=-1)
				{
					String topk[] = line.split("=");
					String sNum = topk[1].trim();
					t1 = Integer.parseInt(sNum);
				}
				if(line.indexOf("TASK2")!=-1)
				{
					String topk[] = line.split("=");
					String sNum = topk[1].trim();
					t2 = Integer.parseInt(sNum);
				}
				if(line.indexOf("TASK3")!=-1)
				{
					String topk[] = line.split("=");
					String sNum = topk[1].trim();
					t3 = Integer.parseInt(sNum);
				}
				if(line.indexOf("TASK4")!=-1)
				{
					String topk[] = line.split("=");
					String sNum = topk[1].trim();
					t4 = Integer.parseInt(sNum);
				}
				if(line.indexOf("TASK5")!=-1)
				{
					String topk[] = line.split("=");
					String sNum = topk[1].trim();
					t5 = Integer.parseInt(sNum);
				}
				if(line.indexOf("TASK6")!=-1)
				{
					String topk[] = line.split("=");
					String sNum = topk[1].trim();
					t6 = Integer.parseInt(sNum);
				}
			}
			bufferedReader.close();
			if(t1 == -1 || t2 == -1 || t3 == -1 || t4 == -1 || t5 == -1 || t6 == -1)
			{
				System.out.println("Topk number read error!");
				System.exit(0);
			}
			System.out.println(user+":" + pass);
			System.out.println("Task1 Topk = " + t1);
			System.out.println("Task2 Topk = " + t2);
			System.out.println("Task3 Topk = " + t3);
			System.out.println("Task4 Topk = " + t4);
			System.out.println("Task5 Topk = " + t5);
			System.out.println("Task6 Topk = " + t6);
			
			connection = DriverManager.getConnection(
					"jdbc:oracle:thin:@oracle.cise.ufl.edu:1521:orcl", user,
					pass);
			
			//PROGRAM STARTS
			
			//DROP REQUIRED TABLES
		/*	Process p = Runtime.getRuntime().exec("source /usr/local/etc/ora11.csh");
			p.waitFor(); */
			System.out.println("Droping and Creating Tables");
			String RUNCOMMAND = "sqlplus " + user + "@" + "orcl/" + pass + " @DropCreateTables.sql";
			System.out.println(RUNCOMMAND);
			Process p = Runtime.getRuntime().exec(RUNCOMMAND);
			p.waitFor();
			{
					String s = "";
					 BufferedReader stdInput = new BufferedReader(new 
				             InputStreamReader(p.getInputStream()));
		
				        BufferedReader stdError = new BufferedReader(new 
				             InputStreamReader(p.getErrorStream()));
		
				        // read the output from the command
				        System.out.println("Here is the standard output of the command:\n");
				        while ((s = stdInput.readLine()) != null) {
				            System.out.println(s);
				        }
		
				        // read any errors from the attempted command
				        System.out.println("Here is the standard error of the command (if any):\n");
				        while ((s = stdError.readLine()) != null) {
				            System.out.println(s);
				        }
			}
			//LOAD DATA
			System.out.println("loading data...");
			RUNCOMMAND = "sqlldr "+user+"@orcl/"+pass+" control = QUERIES.ctl log = Queries.log";
			p = Runtime.getRuntime().exec(RUNCOMMAND);
			p.waitFor();
			
			RUNCOMMAND = "sqlldr "+user+"@orcl/"+pass+" control = ADVERTISERS.ctl log = Queries.log";
			p = Runtime.getRuntime().exec(RUNCOMMAND);
			p.waitFor();
			
			RUNCOMMAND = "sqlldr "+user+"@orcl/"+pass+" control = KEYWORDS.ctl log = Queries.log";
			p = Runtime.getRuntime().exec(RUNCOMMAND);
			p.waitFor();
			
			System.out.println("Creating temporary tables for prgram use...");
			//DROP AND CREATE TEMPORARY TABLES
			RUNCOMMAND = "sqlplus " + user + "@" + "orcl/" + pass + " @DropCreateTempTables.sql";
			p = Runtime.getRuntime().exec(RUNCOMMAND);
			p.waitFor();
			{
					String s = "";
					 BufferedReader stdInput = new BufferedReader(new 
				             InputStreamReader(p.getInputStream()));
		
				        BufferedReader stdError = new BufferedReader(new 
				             InputStreamReader(p.getErrorStream()));
		
				        // read the output from the command
				        System.out.println("Here is the standard output of the command:\n");
				        while ((s = stdInput.readLine()) != null) {
				            System.out.println(s);
				        }
		
				        // read any errors from the attempted command
				        System.out.println("Here is the standard error of the command (if any):\n");
				        while ((s = stdError.readLine()) != null) {
				            System.out.println(s);
				        }
			}
			
			//CREATE FUNCTIONS
			System.out.println("Creating functions...");
			
			RUNCOMMAND = "sqlplus " + user + "@" + "orcl/" + pass + " @FUNCTIONS.sql";
			p = Runtime.getRuntime().exec(RUNCOMMAND);
			p.waitFor();
			{
					String s = "";
					 BufferedReader stdInput = new BufferedReader(new 
				             InputStreamReader(p.getInputStream()));
		
				        BufferedReader stdError = new BufferedReader(new 
				             InputStreamReader(p.getErrorStream()));
		
				        // read the output from the command
				        System.out.println("Here is the standard output of the command:\n");
				        while ((s = stdInput.readLine()) != null) {
				            System.out.println(s);
				        }
		
				        // read any errors from the attempted command
				        System.out.println("Here is the standard error of the command (if any):\n");
				        while ((s = stdError.readLine()) != null) {
				            System.out.println(s);
				        }
			}
			//READ NUMBER OF QUERIES
			
			Statement stmt = connection.createStatement ();
		    ResultSet rset = stmt.executeQuery ("select count(*) as c from queries");
		    int maxQueries = 0;
		    while(rset.next())
		    {
		    	maxQueries = rset.getInt("c");
		    	System.out.println("Max # of queries = " + maxQueries);
		    }
	
		    /*while (rset.next ())
		      System.out.println (rset.getInt("EID") + ", " + rset.getString("ENAME"));*/
		    System.out.println("Executing Test Case 1");
		    rset = stmt.executeQuery ("select tester(" + maxQueries + "," + "1" + "," + t1+ ") from dual");
		    
		    rset = stmt.executeQuery ("select qid, rank, advertiserid, balance, budget1 from task1ads order by qid, rank");
		    
		    PrintWriter writer = new PrintWriter("system.out.1", "UTF-8");
		    while(rset.next())
		    {
		    	writer.println(rset.getString("qid") + ", " + rset.getString("rank") + ", " +  rset.getString("advertiserid") + ", " +  rset.getString("balance") + ", " + rset.getString("budget1"));
		    }
		    writer.close();
		    
		    
		    //TEST CASE 2
		    System.out.println("Executing Test Case 2");
		    rset = stmt.executeQuery ("select tester(" + maxQueries + "," + "2" + "," + t2+ ") from dual");
		    
		    rset = stmt.executeQuery ("select qid, rank, advertiserid, balance, budget1 from task12ads order by qid, rank");
		    
		     writer = new PrintWriter("system.out.2", "UTF-8");
		    while(rset.next())
		    {
		    	writer.println(rset.getString("qid") + ", " + rset.getString("rank") + ", " +  rset.getString("advertiserid") + ", " +  rset.getString("balance") + ", " + rset.getString("budget1"));
		    }
		    writer.close();
		    
		    
		    
		    //TEST CASE3
		    System.out.println("Executing Test Case 3");
		    rset = stmt.executeQuery ("select tester(" + maxQueries + "," + "3" + "," + t3+ ") from dual");
		    
		    rset = stmt.executeQuery ("select qid, rank, advertiserid, balance, budget1 from task2ads order by qid, rank");
		    
		    writer = new PrintWriter("system.out.3", "UTF-8");
		    while(rset.next())
		    {
		    	writer.println(rset.getString("qid") + ", " + rset.getString("rank") + ", " +  rset.getString("advertiserid") + ", " +  rset.getString("balance") + ", " + rset.getString("budget1"));
		    }
		    writer.close();
		    
		    
		    //TEST CASE 4
		    System.out.println("Executing Test Case 4");
		    rset = stmt.executeQuery ("select tester(" + maxQueries + "," + "4" + "," + t4+ ") from dual");
		    
		    rset = stmt.executeQuery ("select qid, rank, advertiserid, balance, budget1 from task22ads order by qid, rank");
		    
		    writer = new PrintWriter("system.out.4", "UTF-8");
		    while(rset.next())
		    {
		    	writer.println(rset.getString("qid") + ", " + rset.getString("rank") + ", " +  rset.getString("advertiserid") + ", " +  rset.getString("balance") + ", " + rset.getString("budget1"));
		    }
		    writer.close();
		    //TEST CASE5
		    System.out.println("Executing Test Case 5");
		    rset = stmt.executeQuery ("select tester(" + maxQueries + "," + "5" + "," + t5+ ") from dual");
		    
		    rset = stmt.executeQuery ("select qid, rank, advertiserid, balance, budget1 from task3ads order by qid, rank");
		    
		    writer = new PrintWriter("system.out.5", "UTF-8");
		    while(rset.next())
		    {
		    	writer.println(rset.getString("qid") + ", " + rset.getString("rank") + ", " +  rset.getString("advertiserid") + ", " +  rset.getString("balance") + ", " + rset.getString("budget1"));
		    }
		    writer.close();
		    //TEST CASE 6
		    System.out.println("Executing Test Case 6");
		    rset = stmt.executeQuery ("select tester(" + maxQueries + "," + "6" + "," + t6+ ") from dual");
		    
		    rset = stmt.executeQuery ("select qid, rank, advertiserid, balance, budget1 from task32ads order by qid, rank");
		    
		    writer = new PrintWriter("system.out.6", "UTF-8");
		    while(rset.next())
		    {
		    	writer.println(rset.getString("qid") + ", " + rset.getString("rank") + ", " +  rset.getString("advertiserid") + ", " +  rset.getString("balance") + ", " + rset.getString("budget1"));
		    }
		    writer.close();
		    
			
			//PROGRAM ENDS
			
			connection.close();
 
		} catch (SQLException e) {
 
			System.out.println("Connection Failed! Check output console");
			e.printStackTrace();
			return;
 
		} catch (FileNotFoundException e) {
			System.out.println("system.in File Not Found in the directory");
			e.printStackTrace();
		} catch (IOException e) {
			System.out.println("Cannot Read From File");
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
 
		if (connection != null) {
			System.out.println("You made it, take control your database now!");
		} else {
			System.out.println("Failed to make connection!");
		}
	}

}

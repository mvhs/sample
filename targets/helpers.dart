// targets uses this file to test your code
// Changing it will not improve your grade
// It will only make it harder for you to run tests
import 'dart:io';
import 'dart:convert';

abstract class Target{
    Function test;
    String name;
    String error;
}

/// This creates an unscored target
/// [test] should return a bool
class TestTarget extends Target{
    Function test = ()=>false;
    String name;

    TestTarget(this.name, [Function test()]);
}

/// This creates a scored target
/// [test] can return a number (equal to points earned)
/// or a bool (true is full credit, false is no credit)
class ScoredTarget extends Target{
    Function test = ()=>0;
    String name;
    num points;

    ScoredTarget(this.name, this.points);
}

/// This creates a TestTarget that passes standard input
/// to a program that is run and checks if the output
/// matches what's provided
/// This involves several hacks, so it may break in the future
/// Also, using this will require you to download code and
/// batch test, as dart:io isn't available in the browser
class IOTarget extends TestTarget{

    /// command - Command that input is passed to
    /// input - Input (string or file) to pass to command
    /// output - Output (string or file) to match against command output
    /// preCommand - Command or list of commands to run
    ///             before passing in input
    /// postCommand - Command or list commands to run
    ///             after passing in input
    IOTarget(String name, String command, var input, var output, 
                        [var preCommand, var postCommand]):super(name){
        test = (){
            if(input is File){
                input = input.readAsStringSync().replaceAll("\r\n","\n");
            }
            if(output is File){
                output = output.readAsStringSync().replaceAll("\r\n","\n");
            }
            if(preCommand!=null){
                if(preCommand is String) runCommand(preCommand);
                else{
                    for(String str in preCommand) runCommand(str);
                }
            }
            var parts = command.split(" ");
            var exe = parts.removeAt(0);
            String pstr = "";
            for(String str in parts){
                pstr+="'$str',";
            }
            new File(".tempscript.dart").writeAsStringSync('''import 'dart:io';
import 'dart:convert';
main(){
    Process.start("$exe",[$pstr]).then((process) {
        process.stdout.transform(UTF8.decoder)
                .transform(new LineSplitter()).listen((data){
            stdout.writeln(data);
        });
        for(String str in """$input""".split("\\n")){
            process.stdin.writeln(str);
        }
        process.stdin.close();
    });
}
''');
            String out = Process.runSync('dart',['.tempscript.dart']).stdout;
            out = out.replaceAll("\r\n","\n");
            if(postCommand!=null){
                if(postCommand is String) runCommand(postCommand);
                else{
                    for(String str in postCommand) runCommand(str);
                }
            }
            if(Platform.isWindows) Process.runSync('del',['.tempscript.dart'],runInShell:true);
            else Process.runSync('rm',['.tempscript.dart']);
            bool result = output==out||output+"\n"==out;
            if(!result){
                this.error = "Expected $output, got $out";
            }
            return result;
        };
    }

    runCommand(String command){
        var parts = command.split(" ");
        var exe = parts.removeAt(0);
        if(exe=="rm"&&Platform.isWindows){
            exe = "del";
        }
        Process.runSync(exe, parts, runInShell:true);
    }

    /// Generates a single IOTarget for a Java program
    static IOTarget makeJava(String mainClass, InputOutput io){
        String pre = "javac $mainClass.java";
        String command = "java $mainClass";
        if(io.args != null) command += " ${io.args}";
        return new IOTarget(io.name, command, input, output, pre);
    }

    /// Generates multiple IOTargets for a single Java program
    /// Only compiles when the first target is run
    static List<IOTarget> makeMultiJava(String mainClass, List<InputOutput> ios){
        List<IOTarget> targets = [];
        for(InputOutput io in ios){
            String pre = null;
            if(targets.length==0) pre = "javac $mainClass.java";
            String command = "java $mainClass";
            if(io.args!=null) command += " ${io.args}";
            targets.add(new IOTarget(io.name, command, io.input, io.output, pre));
        }
        return targets;
    }

    /// (e.g.) make("python3 square.py", new InputOutput("Test","4","16"))
    static IOTarget make(String command, InputOutput io){
        if(io.args != null) command += "${io.args}";
        return new IOTarget(io.name, command, io.input, io.output);
    }

    static List<IOTarget> makeMulti(String command, List<InputOutput> ios){
        List<IOTarget> targets = [];
        for(InputOutput io in ios){
            targets.add(make(command, io));
        }
        return targets;
    }
}

/// This class is used to represent some combination
/// of arguments, input, and expected output
class InputOutput{
    /// These can be Strings or Files
    var input = "";
    var output;

    /// This is arguments on the command, separated by spaces
    String args;

    /// This is the name of the test for this InputOutput
    String name;

    InputOutput(this.name, this.input, this.output);

    InputOutput.withArgsInput(this.name, this.args, this.input, this.output);

    InputOutput.withArgs(this.name, this.args, this.output);
}
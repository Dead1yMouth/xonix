unit ScoreBoard;

interface
uses GraphABC;

procedure addnew(Nickname:string[10]; Score:integer);

implementation
  
  //Добавление нового имени и результата
  procedure addnew(Nickname:string[10]; Score:integer);
  type player = record
       Nick:string[10];
       Score:integer;  
       end;
  var 
    Scores:file of player;
    newScores:file of player; 
    i,j,k,maxim:integer;
    out,a,b:player;
    Name:string[10];
  begin
    Assign(Scores,'Scores.dat');
    Assign(newScores,'newScores.dat');
    Rewrite(newScores);
    Reset(Scores);
    
    a.Nick:=Nickname;
    a.Score:= Score;
    Seek(Scores,FileSize(Scores));
    Write(Scores, a);
    
    out.Score:=-1;
    for j:=0 to (FileSize(Scores)-1) do
    begin
      k:=-1;
      maxim := 0;
      for i:=0 to (FileSize(Scores)-1) do
      begin
        Seek(Scores,i);
        Read(Scores,a);
        if a.Score >= maxim then
        begin
          maxim:=a.Score;
          Name:=a.Nick;
          k:=i;
        end;
      end;
      Seek(Scores,k);
      write(Scores,out);
      b.Score:=maxim;
      b.Nick := Name;
      write(newScores,b);
    end;
    
    Seek(newScores,10);
    Truncate(newScores);
    
    Close(Scores);
    Erase(Scores);
    Close(newScores);
    Rename(newScores, 'Scores.dat');
  end;
  
  
end.
unit Menu;

interface//===========================================

uses GraphABC;
uses Events;

procedure DrawMenu();
procedure DrawRules();
procedure DrawScoreBoard();
procedure DrawInformation();

procedure drawButton(x, y, x1, y1, i: integer);
procedure KeyDownMenu(key: integer);
procedure KeyDownRules(key: integer);
procedure KeyDownScore(key: integer);
procedure KeyDownInformation(key: integer);
const
//массив нужный для отрисовки кнопок и отслеживания активной кнопки.
  Buttons: array[1..6] of string = ('Играть', 'Правила', 'Рекорды', 'Cведения', 'Выход', 'Назад');

var
  State: string; //Cтадия окна
  GameFlag: boolean;//флаг начала игры
  active: integer;//переменная нужная для отслеживания активной кнопки

implementation//======================================

procedure drawButton(x, y, x1, y1, i: integer); //Рисует кнопки
begin
  SetFontSize(20);
  if i = active then
  begin
    SetPenColor(clWhite);
    SetPenWidth(5);
    SetBrushColor(clBlack);
    SetFontColor(clWhite);
  end
    else
  begin
    SetFontColor(clBlack);
    SetBrushcolor(clWhite);
    SetPenColor(clWhite);
    SetPenWidth(1);
  end;
  rectangle(x, y, x1, y1);
  DrawTextCentered(x, y, x1, y1, Buttons[i]);
end;

procedure DrawMenu(); //Рисует меню
begin
  State := 'Menu';
  ClearWindow(clBlack);
  SetFontColor(clWhite);
  SetFontName('Impact');
  SetFontSize(90);
  DrawTextCentered(100, 50, 700, 200, 'XONIX');
  
  drawButton(300, 225, 500, 275, 1);
  drawButton(300, 300, 500, 350, 2);
  drawButton(300, 375, 500, 425, 3);
  drawButton(300, 450, 500, 500, 4);
  drawButton(300, 525, 500, 575, 5);
end;

procedure DrawRules(); //Рисует правила
var
  f: text;
  i: integer;
  line: string;
begin
  State := 'Rules';
  ClearWindow(clBlack);
  drawButton(300, 450, 500, 500, 6);
  
  assign(f, 'rules.txt');
  SetFontSize(16);
  SetFontColor(clWhite);
  reset(f);
  while not eof(f) do //вывод текста из правил
  begin
    readln(f, line);
    DrawTextCentered(0, 0, 800, 400, line);
  end;
  Close(f);    
end;

procedure DrawScoreBoard(); //вывод таблицы рекордов
type
  player = record
    Nick: string[10];
    Score: integer; 
  end;
var
  a: player;
  Score: file of player;
  y, i: integer;
const
  x = 320;
begin
  State := 'Score';
  ClearWindow(clBlack);
  drawButton(300, 450, 500, 500, 6);
  SetFontColor(clWhite);
  SetFontSize(15);
  DrawTextCentered(300, 20, 500, 40, 'Таблица рекордов');
  
  Assign(Score, 'Scores.dat');
  Reset(Score);
  y := 65;
  i := 1;
  while not eof(Score) do
  begin
    Read(Score, a);
    TextOut(x - 25, y, IntToStr(i) + '. ');
    TextOut(x, y, a.Nick);
    TextOut(x + 165, y, IntToStr(a.Score));
    y := y + 35;
    i := i + 1;
  end;
  Close(Score);
end;

procedure DrawInformation(); //вывод сведений
var
  f: text;
  y, i: integer;
  line: string;
begin
  State := 'Information';
  ClearWindow(clBlack);
  drawButton(300, 450, 500, 500, 6);
  
  Assign(f, 'information.txt');
  SetFontSize(16);
  SetFontColor(clWhite);
  Reset(f);
  y:=50;
  while not eof(f) do //вывод Сведений
  begin
    readln(f, line);
    TextOut(50, y, line);
    y:=y+25;
  end;
  Close(f);
end;

procedure KeyDownMenu(key: integer); // Обработчик нажатий клавишь в меню
begin    
  if (key = VK_S) then
  begin
    if (active = 5) then
      active := 1
    else 
      active := active + 1;
  end;
  
  if (key = VK_W) then
  begin
    if (active = 1) then
      active := 5
    else 
      active := active - 1;
  end;
  
  if (key = VK_ENTER) then
  begin
    case active of
      1: GameFlag := true;
      2: begin DrawRules; active := 6; end;
      3: begin DrawScoreBoard; active := 6; end;
      4: begin DrawInformation; active := 6; end;
      5: CloseWindow;
    end;
  end;
end;

procedure KeyDownRules(key: integer);
begin
  if (key = VK_ENTER) then
  begin
    DrawMenu;
    active := 2;
  end;
end;

procedure KeyDownInformation(key: integer);
begin
  if (key = VK_ENTER) then
  begin
    DrawMenu;
    active := 4;
  end;
end;

procedure KeyDownScore(key: integer);
begin
  if (key = VK_ENTER) then
  begin
    DrawMenu;
    active := 3;
  end;
end;

begin
  active := 1;

end.
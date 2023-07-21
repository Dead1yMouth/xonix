{Модуль занимается отрисовкой игрового поля,}
{ отображением всех его объектов и ячеек,   }
{ а также вычислением всего процесса игры   }
unit Game;
interface
uses GraphABC;
  uses Events;
uses ScoreBoard;

procedure DrawField();
procedure GameOver();
procedure EscapePressed();
procedure SetPlayer();
procedure KeyDownGame(key: integer);
procedure BallMovement(i: integer);
procedure BallCirucuit();
procedure DrawBall(x, y, r: integer);
procedure Coloring(x, y: integer);
procedure NewLevel();
procedure GenerateFieldCords;
procedure GenerateBallCords;
procedure Escape(key: integer);
procedure InputName(key: char);
procedure DeleteName(key: integer);

const
  Ht = 24;
  Lt = 44;
  
  //Стадии клетки
  Wall = 1;
  FieldS = 2;
  Circuit = 3;
  BallArea = 4;
  
  //стартовые значения персонажа
  StartPlayerX = 55;
  StartPlayerY = 65;
  
  //Константы для нахождения координат относительно поля
  FieldX = 70;
  FieldY = 80;
  CellSize = 15;
  
  //Размерные константы
  {Персонажа}
  plSpeed = 15;
  len = 15;
  {Шара}
  rbl = 7;
  blSpeed = 15;

type //Записи для ячеек поля
  Cells = record
    x: integer;
    y: integer;
    State: integer;
  end;

type //записи для координат шаров
  BallCords = record
    x: integer;
    y: integer;
    OnFieldX: integer;
    OnFieldY: integer;
    Xspeed: integer;
    Yspeed: integer;
  end;

var
  //переменные поля
  exitFlag: boolean;
  escapeFlag: boolean;
  lossFlag: boolean;
  lives: integer;
  Score: integer;
  AreaCounter: integer;
  pause: boolean;
  Name: string;
  
  //игрок
  ypl, xpl, mov: integer;
  xplOnField, yplOnField: integer;
  CircuitFlag: boolean;
  
  //шары
  BallCounter: integer;
  Balls: array[1..11] of BallCords;
  
  //поле
  Field: array[-1..Lt + 2, -1..Ht + 2] of Cells;
  i, j: integer;
  xCell, yCell: integer;

//==========================================
implementation

//нажатие клавиши escape
procedure EscapePressed();//Пауза/выход
begin
  setfontsize(25);
  SetPenColor(clWhite);
  SetPenWidth(3);
  DrawRectangle(510, 484, 750, 576);
  DrawTextCentered(510, 484, 750, 576, 'Выйти? Y/N');
  Redraw;
  while escapeFlag do
  begin
    OnKeyDown := Escape;
  end;
end;

//конец игры
procedure GameOver();
begin
  lossFlag := true;
    SetFontColor(clWhite);
    SetBrushColor(clBlack);
    SetPenColor(clWhite);
    Name := '';
    while lossFlag = true do
    begin
      OnKeyPress := InputName;
      OnKeyDown := DeleteName;
      Rectangle(200, 200, 600, 400);
      DrawTextCentered(200, 200, 600, 260, 'Game Over');
      DrawTextCentered(200, 240, 600, 300, 'Колличество очков - ' + IntToStr(Score));
      DrawTextCentered(200, 280, 600, 340, 'Введите имя: ');
      DrawTextCentered(200, 350, 600, 370, Name);
      Redraw;
    end;
    addnew(Name, Score)
end;

//прорисовка поля
procedure DrawField();
var
  i, j: integer;
begin    
  ClearWindow(clBlack);
  SetPenColor(clWhite);
  SetPenWidth(1);
  for i := 0 to Lt - 1 do//закрашивает каждую клетку
    for j := 0 to Ht - 1 do
    begin
      if Field[i, j].State = FieldS then 
      begin
        SetBrushColor(clWhite);
        Rectangle(Field[i, j].x, Field[i, j].y, Field[i, j].x + CellSize, Field[i, j].y + CellSize);
      end;
      if Field[i, j].State = Circuit then
      begin
        SetBrushColor(clMaroon);
        FillRectangle(Field[i, j].x, Field[i, j].y, Field[i, j].x + CellSize, Field[i, j].y + CellSize);
      end;
      if Field[i, j].State = Wall then
      begin
        SetBrushColor(clBlack);
        FillRectangle(Field[i, j].x, Field[i, j].y, Field[i, j].x + CellSize, Field[i, j].y + CellSize);
      end;
    end;
  SetPenWidth(3);
  DrawRectangle(53, 63, 747, 457);
  
  SetFontColor(clWhite);
  SetFontSize(20);
  DrawTextCentered( 50, 484, 200, 576, ('Жизни: ' + IntToStr(Lives)));
  DrawTextCentered( 190, 484, 340, 576, ('Очки: ' + IntToStr(Score)));
  DrawTextCentered( 350, 484, 500, 576, ('Уровень: ' + IntToStr(BallCounter)));  
end;

//прорисовка персонажа
procedure SetPlayer();
begin
  SetPenWidth(1);
  SetBrushcolor(clRed);
  SetPenColor(clRed);
  Rectangle(xpl, ypl, xpl + CellSize, ypl + CellSize);
  SetbrushColor(clWhite);
  FillRectangle(xpl + 5, ypl + 5, xpl + CellSize - 5, ypl + CellSize - 5)
end;

//Нажатие клавишь в игре
procedure KeyDownGame(key: integer);
begin
  case key of
    VK_W: mov := 1;
    VK_A: mov := 2;
    VK_S: mov := 3;
    VK_D: mov :=4;
    VK_Escape: escapeFlag :=true;
  end;
end;

//нажатие клавишь при паузе
procedure Escape(key: integer);
begin
  if (key = VK_Y) then 
  begin
    exitFlag := true;
    mov := 0;
    escapeFlag := false;
  end;
  if (key = VK_N) then escapeFlag := False;
  
end;

//Вписывание имени
procedure InputName(key: char);
begin
  if  ((key in 'A'..'Z') or (key in 'a'..'z') or (key in '0'..'9')) and (Length(Name) < 10) then
    Name := Name + key;
end;

//Нажатие клавишь при вписывании имени
procedure DeleteName(key: integer);
begin
  if (key = VK_BACK) then Delete(Name, Length(Name), 1);
  if (key = VK_Enter) then 
  begin
    lossFlag := false; exitFlag := true;
  end;
end;

//Движение шара
procedure BallMovement(i: integer);
var
  xblOnField, yblOnField: integer;
begin
  xblOnField := Balls[i].OnFieldX;
  yblOnField := Balls[i].OnFieldY;
  
  if   ((Field[xblOnField - 1, yblOnField].State = Wall) and (Field[xblOnField, yblOnField - 1].State = Wall))
    or ((Field[xblOnField + 1, yblOnField].State = Wall) and (Field[xblOnField, yblOnField + 1].State = Wall))
    or ((Field[xblOnField - 1, yblOnField].State = Wall) and (Field[xblOnField, yblOnField + 1].State = Wall))
    or ((Field[xblOnField + 1, yblOnField].State = Wall) and (Field[xblOnField, yblOnField - 1].State = Wall)) then //угол
  begin
    Balls[i].Xspeed := -Balls[i].Xspeed;
    Balls[i].Yspeed := -Balls[i].Yspeed;
  end
    else
    if (Field[xblOnField, yblOnField - 1].State = Wall) or (Field[xblOnField, yblOnField + 1].State = Wall) then //верх\низ
    begin
      Balls[i].Yspeed := -Balls[i].Yspeed;
    end
      else  
      if (Field[xblOnField - 1, yblOnField].State = Wall) or (Field[xblOnField + 1, yblOnField].State = Wall) then //лево\право
      begin
        Balls[i].Xspeed := -Balls[i].Xspeed;
      end
        else
        if ((Field[xblOnField + 1, yblOnField + 1].State = Wall) and (Balls[i].Xspeed > 0) and (Balls[i].Xspeed > 0))
        or ((Field[xblOnField - 1, yblOnField - 1].State = Wall) and (Balls[i].Xspeed < 0) and (Balls[i].Xspeed < 0))
        or ((Field[xblOnField + 1, yblOnField - 1].State = Wall) and (Balls[i].Xspeed > 0) and (Balls[i].Xspeed < 0))
        or ((Field[xblOnField - 1, yblOnField + 1].State = Wall) and (Balls[i].Xspeed < 0) and (Balls[i].Xspeed > 0)) then
        begin
          Balls[i].Xspeed := -Balls[i].Xspeed;
          Balls[i].Yspeed := -Balls[i].Yspeed;
        end;
end;

//Коллизия шара с цепью
procedure BallCirucuit;
var
  i, j: integer;
begin
  CircuitFlag := false;
  xpl := StartPlayerX;
  ypl := StartPlayerY;
  mov := 0;//оставновка персонажа
  lives := lives - 1;
  Sleep(500);
  
  //закрашивает каждую клетку
  for i := 0 to Lt - 1 do
    for j := 0 to Ht - 1 do
    begin
      if Field[i, j].State = Circuit then Field[i, j].State := FieldS;
    end;
end;

//Генерирует координаты клеток в поле и изначальные значения стадий клеток
procedure GenerateFieldCords;
var
  i, j: integer;
begin
  exitFlag := False;
  yCell := 80;
  for j := 0 to Ht - 1 do
  begin
    xCell := 55;
    for i := 0 to Lt - 1 do
    begin
      Field[i, j].x := xCell + CellSize;
      Field[i, j].y := yCell;
      Field[i, j].State := FieldS;
      xCell := xCell + CellSize
    end;
    yCell := yCell + CellSize;
  end;
  for j := -1 to Ht do Field[-1, j].State := Wall;
  for i := -1 to Lt do Field[i, -1].State := Wall;
  for j := -1 to Ht do Field[Lt, j].State := Wall;
  for i := -1 to Lt do Field[i, Ht].State := Wall;
end;

//генерирует начальное положение шаров и их напрваления движения
procedure GenerateBallCords;
var
  i: integer;
  RandomDir, RandomX, RandomY: integer;
begin
  Randomize;
  for i := 1 to 10 do
  begin
    RandomDir := Random(3);
    case RandomDir of
      0:
        begin
          Balls[i].Xspeed := blSpeed;
          Balls[i].Yspeed := blSpeed;
        end;
      1:
        begin
          Balls[i].Xspeed := -blSpeed;
          Balls[i].Yspeed := -blSpeed;
        end;
      2:
        begin
          Balls[i].Xspeed := blSpeed;
          Balls[i].Yspeed := -blSpeed;
        end;
      3:
        begin
          Balls[i].Xspeed := -blSpeed;
          Balls[i].Yspeed := blSpeed;
        end;
    end;
    RandomX := Random(Lt - 2) + 1;
    RandomY := Random(Ht - 2) + 1;
    Balls[i].x := Field[RandomX, RandomY].x;
    Balls[i].y := Field[RandomX, RandomY].y;
  end;
end;

procedure DrawBall(x, y, r: integer);
begin
  SetBrushColor(clBlue);
  FillCircle(x + r, y + r, r);
end;

//Закрашивание областей
procedure Coloring(x, y: integer);
const
  FieldS = 2;
  BallArea = 4;
begin
  if (Field[x, y].State = BallArea) or (Field[x, y].State = Wall) or (Field[x, y].State = Circuit) then exit
    else
  begin
    Field[x, y].State := BallArea;
    Coloring(x + 1, y);
    Coloring(x - 1, y);
    Coloring(x, y + 1);
    Coloring(x, y - 1);
  end;
end;

//Переход на новый уровень
procedure NewLevel();
var
  i, j: integer;
begin
  Sleep(500);
  AreaCounter := 0;
  xpl := StartPlayerX; 
  ypl := StartPlayerY;
  CircuitFlag := false;
  mov := 0;
  BallCounter := BallCounter + 1;
  GenerateBallCords;
  for i := 0 to Lt - 1 do
    for j := 0 to Ht - 1 do
    begin
      Field[i, j].State := FieldS
    end;
end;

end. 
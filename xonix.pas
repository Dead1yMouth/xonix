uses GraphABC;
uses Events;
uses Menu;
uses Game;

var
  i, j: integer;

begin
  SetWindowSize(800, 600);
  SetWindowIsFixedSize(True);
  SetWindowCaption('XONIX');
  ClearWindow(clBlack);
  SetFontColor(clWhite);
  SetFontName('Impact');
  SetFontSize(130);
  
  //Заставка
  DrawTextCentered(0, 0, 800, 600, 'XONIX');
  SetFontSize(20);
  DrawTextCentered(200, 375, 600, 450, 'сделал студент группы 143 Смирнов Вадим');
  Sleep(3000);
  
  LockDrawing;
  DrawMenu;
  GameFlag := False;
  SetFontName('Impact');
  
  while true do
  begin
    //меню и подменю
    case State of
      'Menu': 
        begin
          OnKeyDown := KeyDownMenu;
          DrawMenu;
        end;
      'Rules': 
        begin
          OnKeyDown := KeyDownRules;
          DrawRules;
        end;
      'Score':
        begin
          OnKeyDown := KeyDownScore;
          DrawScoreBoard;
        end;
      'Information':
        begin
          OnKeyDown := KeyDownInformation;
          DrawInformation;
        end;
    end;    
    
    if GameFlag then //тригер начала игры
    begin
      exitFlag := False;
      
      //игрок
      xpl := StartPlayerX; 
      ypl := StartPlayerY;
      lives := 5;
      Score := 0;
      
      //шарик
      BallCounter := 1;
      
      //Генерирует координаты клеток в поле и начальные значения стадий клеток
      GenerateFieldCords;
      
      //генерирует начальное положение шаров и их напрваления движения
      GenerateBallCords;
      
      //ПРОЦЕСС ИГРЫ
      while True do
      begin
        
        //Выход
        if exitFlag then
        begin
          break;
        end;
        
        //Триггер перехода на новый уровень
        if AreaCounter >= (Ht * Lt) * 0.7 then 
        begin
          NewLevel;
        end;
        
        //нажатие клавишь и движение
        OnKeyDown := KeyDownGame;
        if mov = 1 then if ypl > 78 then ypl -= plSpeed;
        if mov = 2 then if xpl > 68 then xpl -= plSpeed;
        if mov = 3 then if ypl < 440 then ypl += plSpeed;                                    
        if mov = 4 then if xpl < 730 then xpl += plSpeed;
        
        //закрашивание цепи
        xplOnField := (xpl - FieldX) div CellSize;
        yplOnField := (ypl - FieldY) div CellSize;
        if (Field[xplOnField, yplOnField].State = FieldS) then 
        begin
          Field[xplOnField, yplOnField].State := Circuit;
          CircuitFlag := True;
        end;
        
        //движение шаров
        for i := 1 to BallCounter do
        begin
          BallMovement(i);
          Balls[i].x := Balls[i].x + Balls[i].Xspeed;
          Balls[i].y := Balls[i].y + Balls[i].Yspeed;
          Balls[i].OnFieldX := (Balls[i].x - FieldX) div CellSize;
          Balls[i].OnFieldY := (Balls[i].y - FieldY) div CellSize;
          //коллизия шара с цепью
          if (Field[ Balls[i].OnFieldX, Balls[i].OnFieldY].State = Circuit) then 
            BallCirucuit;
        end;
        
        
        //проигрышь/выигрышь
        if (lives < 0) or (BallCounter > 10) then
        begin
          GameOver;
        end;
        
        //закрашивание области
        if CircuitFlag and (Field[xplOnField, yplOnField].State = Wall) then
        begin
          for i := 1 to BallCounter do 
            Coloring(Balls[i].OnFieldX, Balls[i].OnFieldY);//Закрашивание зоны шаров
          for i := 0 to Lt - 1 do
            for j := 0 to Ht - 1 do
            begin
              if (Field[i, j].State = FieldS) or (Field[i, j].State = Circuit)  then //закрашивание поля в стену
              begin
                Field[i, j].State := Wall;
                Score := Score + 1;//+ в очки
                AreaCounter := AreaCounter + 1;              
              end;
              if Field[i, j].State = BallArea then Field[i, j].State := FieldS;  //закрашивание зоны шаров обратно в поле
            end;
          CircuitFlag := false;
        end;
        
        //нажатие escape
        if escapeFlag then
        begin
          EscapePressed;
        end;
        
        //перерисовка поля, шаров и персонажа
        DrawField;
        SetPlayer;
        for i := 1 to BallCounter do
          DrawBall(Balls[i].x, Balls[i].y, rbl);
        
        Redraw;
        Sleep(15);//скорость игры
      end;      
      State := 'Menu';
      GameFlag := false;
    end;
    Redraw;
    sleep(100);
  end;
end.

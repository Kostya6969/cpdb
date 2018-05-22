#Использовать cmdline
#Использовать readparams
#Использовать v8runner
#Использовать yadisk
#Использовать logos
#Использовать "."

Перем Лог Экспорт; // Общий логер приложения

Функция ПолучитьПарсерКоманднойСтроки()
    
    Парсер = Новый ПарсерАргументовКоманднойСтроки();
    
    МенеджерКомандПриложения.ЗарегистрироватьКоманды(Парсер);
    
    Возврат Парсер;
    
КонецФункции // ПолучитьПарсерКоманднойСтроки()

Функция ПолезнаяРабота()

    ПараметрыЗапуска = РазобратьАргументыКоманднойСтроки();
    Если ПараметрыЗапуска = Неопределено ИЛИ ПараметрыЗапуска.Количество() = 0 Тогда
        Лог.Ошибка("Некорректные аргументы командной строки");
        МенеджерКомандПриложения.ПоказатьСправкуПоКомандам();
        Возврат 1;
    КонецЕсли;
    
    Возврат МенеджерКомандПриложения.ВыполнитьКоманду(ПараметрыЗапуска.Команда, ПараметрыЗапуска.ЗначенияПараметров);
    
КонецФункции // ПолезнаяРабота()

Функция РазобратьАргументыКоманднойСтроки()

    Парсер = ПолучитьПарсерКоманднойСтроки();
    Возврат Парсер.Разобрать(АргументыКоманднойСтроки);

КонецФункции // РазобратьАргументыКоманднойСтроки()

/////////////////////////////////////////////////////////////////////////

Лог = Логирование.ПолучитьЛог("ktb.app.cpdb");
УровеньЛога = УровниЛога.Информация;
Лог.УстановитьУровень(УровеньЛога);

Попытка
    ЗавершитьРаботу(ПолезнаяРабота());
Исключение
    Лог.КритичнаяОшибка(ОписаниеОшибки());
    ЗавершитьРаботу(МенеджерКомандПриложения.РезультатыКоманд().ОшибкаВремениВыполнения);
КонецПопытки;


// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;       // - Объект      - объект записи лога приложения

#Область СлужебныйПрограммныйИнтерфейс

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("s src", "", "путь к исходному локальному файлу для разбиения")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_FILE_SPLIT_SRC");
	
	Команда.Опция("a arc", "", "имя файла архива (не обязательный, по умолчанию <имя исходного файла>.7z)")
	       .ТСтрока()
	       .ВОкружении("CPDB_FILE_SPLIT_ARCH");
	
	Команда.Опция("l list", "", "имя файла, списка томов архива (не обязательный, по умолчанию <имя исходного файла>.split)")
	       .ТСтрока()
	       .ВОкружении("CPDB_FILE_SPLIT_LIST");
	
	Команда.Опция("vs vol-size", "50m", "размер части {<g>, <m>, <b>} (по умолчанию 50m)")
	       .ТСтрока()
	       .ВОкружении("CPDB_FILE_SPLIT_SIZE");
	
	Команда.Опция("h hash", Ложь, "рассчитывать MD5-хеши файлов частей")
	       .Флаговый()
	       .ВОкружении("CPDB_FILE_SPLIT_HASH");
	
	Команда.Опция("hf hash-file", "", "Имя файла, списка хэшей томов архива
	                                  |(не обязательный, по умолчанию <имя исходного файла>.hash)")
	       .ТСтрока()
	       .ВОкружении("CPDB_FILE_SPLIT_HASH_FILE");
	
	Команда.Опция("ds delsrc", Ложь, "удалить исходный файл после выполнения операции")
	       .Флаговый()
	       .ВОкружении("CPDB_FILE_SPLIT_DEL_SRC");
	
	Команда.Опция("cl compress-level", "0", "уровень сжатия частей архива {0 - 9} (по умолчанию 0 - не сжимать)")
	       .ТСтрока()
	       .ВОкружении("CPDB_FILE_SPLIT_COMPRESS_LEVEL");
	
КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ВыводОтладочнойИнформации = Команда.ЗначениеОпции("verbose");

	ПараметрыПриложения.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	Если НЕ ПараметрыПриложения.ОбязательныеПараметрыЗаполнены(Команда) Тогда
		Команда.ВывестиСправку();
		Возврат;
	КонецЕсли;

	ПутьКФайлу       = Команда.ЗначениеОпции("src");
	ИмяАрхива        = Команда.ЗначениеОпции("arc");
	ИмяСпискаФайлов  = Команда.ЗначениеОпции("list");
	УдалитьИсточник  = Команда.ЗначениеОпции("delsrc");
	РазбитьНаТома    = Команда.ЗначениеОпции("vol-size");
	РассчитыватьХеши = Команда.ЗначениеОпции("hash");
	ИмяФайлаХэшей    = Команда.ЗначениеОпции("hash-file");
	СтепеньСжатия    = Команда.ЗначениеОпции("compress-level");
	
	КоличествоОтправляемыхФайлов = ЗапаковатьВАрхив(ПутьКФайлу,
	                                                ИмяАрхива,
	                                                ИмяСпискаФайлов,
	                                                РазбитьНаТома,
	                                                РассчитыватьХеши,
	                                                ИмяФайлаХэшей,
	                                                СтепеньСжатия,
	                                                УдалитьИсточник);
	
	Если УдалитьИсточник Тогда
		КомандаУдалитьФайл(ПутьКФайлу);
	КонецЕсли;
	
	УстановитьПеременнуюСреды("AMOUNT_SPLITTED_PARTS", КоличествоОтправляемыхФайлов);

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Интерфейсная процедура, выполняет текущую команду
//   
// Параметры:
//   ПутьКФайлу          - Строка    - путь к файлу, который будет архивироваться
//   ИмяАрхива           - Строка    - имя файла-архива
//   ИмяСпискаФайлов     - Строка    - имя файла-списка (содержащего все чати архива)
//   РазмерТома          - Строка    - размер части {<g>, <m>, <b>} (по умолчанию 50m)
//   РассчитыватьХеши    - Булево    - Истина - будут расчитаны хэш-суммы файлов архива
//   ИмяФайлаХэшей       - Строка    - имя файла списка хэш-сумм
//   СтепеньСжатия       - Число     - уровень сжатия частей архива {0 - 9} (по умолчанию 0 - не сжимать)
//   УдалитьИсточник     - Булево    - удалить исходный файл после выполнения операции
//
// Возвращаемое значение:
//   Число    - количество файлов архива
//
Функция ЗапаковатьВАрхив(Знач ПутьКФайлу,
                         Знач ИмяАрхива,
                         Знач ИмяСпискаФайлов,
                         Знач РазмерТома = Неопределено,
                         Знач РассчитыватьХеши = Ложь,
                         Знач ИмяФайлаХэшей = Неопределено,
                         Знач СтепеньСжатия = 0,
                         Знач УдалитьИсточник = Ложь)

	ПутьК7ЗИП = ЗапускПриложений.Найти7Zip();
	
	Если НЕ ЗначениеЗаполнено(ПутьК7ЗИП) Тогда
		ВызватьИсключение "7-Zip не найден";
	КонецЕсли;

	ДанныеИсхФайла = Новый Файл(ПутьКФайлу);

	Если НЕ ЗначениеЗаполнено(ИмяАрхива) Тогда
		ИмяАрхива = ДанныеИсхФайла.ИмяБезРасширения + ".7z";
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ИмяСпискаФайлов) Тогда
		ИмяСпискаФайлов = ОбъединитьПути(ДанныеИсхФайла.Путь, ДанныеИсхФайла.ИмяБезРасширения + ".split");
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ИмяФайлаХэшей) Тогда
		ИмяФайлаХэшей = ОбъединитьПути(ДанныеИсхФайла.Путь, ДанныеИсхФайла.ИмяБезРасширения + ".hash");
	КонецЕсли;

	ИмяФайлаОшибокАрхивации = ДанныеИсхФайла.Путь + "7z_error_messages.txt";

	КомандаАрхиватора = СтрШаблон("""%1"" a  ""%4"" ""%3"" -t7z -v%2 -mx%5", ПутьК7ЗИП, 
		?(ЗначениеЗаполнено(РазмерТома), РазмерТома, "50m"),
		ПутьКФайлу,
		ИмяАрхива,
		?(ЗначениеЗаполнено(СтепеньСжатия), СтепеньСжатия, 0));
	
	Лог.Отладка("команда архиватора: " + КомандаАрхиватора);
	КодВозврата = 0;
	ЗапуститьПриложение(КомандаАрхиватора, ДанныеИсхФайла.Путь, Истина, КодВозврата);

	Если КодВозврата = 0 Тогда
		Если УдалитьИсточник Тогда
			УдалитьФайлы(ПутьКФайлу);
		КонецЕсли;
		Возврат СоздатьСписокФайлов(ИмяАрхива, ДанныеИсхФайла.Путь, ИмяСпискаФайлов, РассчитыватьХеши, ИмяФайлаХэшей);
	Иначе

		Лог.Ошибка("Архивирование завершилось с ошибкой. Код возврата " + КодВозврата);
		ФайлОшибокАрх = Новый Файл(ИмяФайлаОшибокАрхивации);
		Если ФайлОшибокАрх.Существует() Тогда
			ЧтениеФайла = Новый ЧтениеТекста(ИмяФайлаОшибокАрхивации);
			СтрокаФайлаОшибок = ЧтениеФайла.ПрочитатьСтроку();
			Пока СтрокаФайлаОшибок <> Неопределено Цикл
				Лог.Ошибка(СтрокаФайлаОшибок);
				СтрокаФайлаОшибок = ЧтениеФайла.ПрочитатьСтроку();
			КонецЦикла;
			ЧтениеФайла.Закрыть();
			УдалитьФайлы(ИмяФайлаОшибокАрхивации);
		КонецЕсли;

		Возврат 0;
	КонецЕсли;

КонецФункции // ЗапаковатьВАрхив()

// Функция создает файл-список файлов архива и возвращает количество
//   
// Параметры:
//   ИмяАрхива           - Строка    - имя файла архива
//   КаталогАрхива       - Строка    - путь к каталогу с файлами архива
//   ИмяСпискаФайлов     - Строка    - имя файла-списка файлов архива
//   РассчитыватьХеши    - Булево    - Истина - будут расчитаны хэш-суммы файлов архива
//   ИмяФайлаХэшей       - Строка    - имя файла-списка хэшей файлов архива
//
// Возвращаемое значение:
//   Число - количество файлов архива
//
Функция СоздатьСписокФайлов(ИмяАрхива, КаталогАрхива, ИмяСпискаФайлов, РассчитыватьХеши, ИмяФайлаХэшей)

	МассивФайловЧастей = НайтиФайлы(КаталогАрхива, ИмяАрхива + ".???", Ложь);
	Лог.Отладка("Всего частей: " + МассивФайловЧастей.Количество());

	ЗаписьСписка = Новый ЗаписьТекста(ИмяСпискаФайлов, КодировкаТекста.UTF8, , Ложь);

	Если РассчитыватьХеши Тогда
		ЗаписьХешей = Новый ЗаписьТекста(ИмяФайлаХэшей, КодировкаТекста.UTF8, , Ложь);
		РасчетХешей = Новый ХешированиеДанных(ХешФункция.MD5);
	КонецЕсли;

	Для каждого ФайлЧасти Из МассивФайловЧастей Цикл
		ЗаписьСписка.ЗаписатьСтроку(ФайлЧасти.Имя);

		Если РассчитыватьХеши Тогда
			РасчетХешей.ДобавитьФайл(ФайлЧасти.ПолноеИмя);
			ЗаписьХешей.ЗаписатьСтроку(СтрШаблон("%1 %2", ФайлЧасти.Имя, РасчетХешей.ХешСуммаСтрокой));
			РасчетХешей.Очистить();
		КонецЕсли;

	КонецЦикла;
	ЗаписьСписка.Закрыть();

	Если РассчитыватьХеши Тогда
		ЗаписьХешей.Закрыть();
	КонецЕсли;

	Возврат МассивФайловЧастей.Количество();

КонецФункции // СоздатьСписокФайлов()

// Функция, выполняет удаление указанных файлов
//   
// Параметры:
//   ПутьКФайлу         - Строка         - путь к удаляемому файлы
//
Процедура КомандаУдалитьФайл(ПутьКФайлу)

	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("del");
	КомандаРК.ДобавитьПараметр("/F ");
	КомандаРК.ДобавитьПараметр("/Q ");
	КомандаРК.ДобавитьПараметр(ПутьКФайлу);

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы( Ложь );
	КомандаРК.ПоказыватьВыводНемедленно( Ложь );
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();
	
	Если Не ПустаяСтрока(ОписаниеРезультата) Тогда
		Лог.Информация("Вывод команды удаления: " + ОписаниеРезультата);
	КонецЕсли;

	Если НЕ КодВозврата = 0 Тогда
		ТекстОшибки = СтрШаблон("Ошибка удаления файла ""%1"", код возврата: %2",
		                        ПутьКФайлу,
		                        КодВозврата);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

КонецПроцедуры // КомандаУдалитьФайл()

#КонецОбласти // СлужебныеПроцедурыИФункции

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта()

	Лог = ПараметрыПриложения.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий

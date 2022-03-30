#Использовать 1commands

Перем Лог;           // - Объект    - объект записи лога приложения
Перем Сервер;        // - Строка    - адрес сервера СУБД
Перем Пользователь;  // - Строка    - Пользователь сервера СУБД
Перем Пароль;        // - Строка    - Пароль пользователя сервера СУБД

Функция Сервер() Экспорт

	Возврат Сервер;

КонецФункции // Сервер()

Процедура УстановитьСервер(Знач НовоеЗначение) Экспорт

	Сервер = НовоеЗначение;

КонецПроцедуры // УстановитьСервер()

Функция Пользователь() Экспорт

	Возврат Пользователь;

КонецФункции // Пользователь()

Процедура УстановитьПользователь(Знач НовоеЗначение) Экспорт

	Пользователь = НовоеЗначение;

КонецПроцедуры // УстановитьПользователь()

Процедура УстановитьПароль(Знач НовоеЗначение) Экспорт

	Пароль = НовоеЗначение;

КонецПроцедуры // УстановитьПароль()

////////////////////////////////////////////////////////////////////////////////
// Работа с СУБД

// Функция проверяет существование базу на сервере СУБД
//
// Параметры:
//   База         - Строка       - имя базы данных
//
// Возвращаемое значение:
//   Булево       - Истина - база существует на сервере СУБД
//
Функция БазаСуществует(База) Экспорт

	ТекстЗапроса = СтрШаблон("""SET NOCOUNT ON;
	                         |SELECT
	                         |	COUNT(name)
	                         |FROM
	                         |	sysdatabases
	                         |WHERE
	                         |	name = '%1';
	                         |
	                         |SET NOCOUNT OFF""",
	                         База);
	
	РезультатЗапроса = "";
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса);

	Если КодВозврата = 0 Тогда
		РезультатЗапроса = СокрЛП(СтрЗаменить(РезультатЗапроса, "-", ""));
		Возврат РезультатЗапроса = "1";
	Иначе
		Возврат Ложь;
	КонецЕсли;

КонецФункции // БазаСуществует()

// Функция выполняет команду создания базы на сервере СУБД
//
// Параметры:
//    База                    - Строка    - имя базы данных
//    МодельВосстановления    - Строка    - новая модель восстановления (FULL, SIMPLE, BULK_LOGGED)
//    ОписаниеРезультата      - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево      - Истина - команда выполнена успешно
//
Функция СоздатьБазу(База, МодельВосстановления = "FULL", ОписаниеРезультата = "") Экспорт

	Если БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" уже существует!", База);
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""USE [master];
	                         |
	                         |CREATE DATABASE [%1];
	                         |
	                         |ALTER DATABASE [%1]
	                         |SET RECOVERY %2""",
	                         База,
	                         МодельВосстановления);
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);
	
	Возврат КодВозврата = 0;
	
КонецФункции // СоздатьБазу()

// Функция выполняет команду удаления базы на сервере СУБД
//
// Параметры:
//    База                    - Строка    - имя базы данных
//    ОписаниеРезультата      - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево      - Истина - команда выполнена успешно
//
Функция УдалитьБазу(База, ОписаниеРезультата = "") Экспорт

	Если НЕ БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""USE [master];
	                         |
	                         |DROP DATABASE [%1]""",
	                         База);
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);
	
	Возврат КодВозврата = 0;
	
КонецФункции // УдалитьБазу()

// Функция устанавливает модель восстановления базы
//
// Параметры:
//    База                   - Строка    - имя базы данных
//    МодельВосстановления   - Строка    - новая модель восстановления (FULL, SIMPLE, BULK_LOGGED)
//    ОписаниеРезультата     - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево       - Истина - команда выполнена успешно
//
Функция УстановитьМодельВосстановления(База, МодельВосстановления = "FULL", ОписаниеРезультата = "") Экспорт

	Если ПустаяСтрока(МодельВосстановления) Тогда
		Возврат Истина;
	КонецЕсли;

	Если Найти("FULL,SIMPLE,BULK_LOGGED", ВРег(МодельВосстановления)) = 0 Тогда
		ОписаниеРезультата = СтрШаблон("Указана некорректная модель восстановления ""%1""
		                               | (возможные значения: ""FULL"", ""SIMPLE"", ""BULK_LOGGED"")!",
		                               МодельВосстановления);
		Возврат Ложь;
	КонецЕсли;

	Если НЕ БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""USE [master];
	                         |
	                         |ALTER DATABASE %1
	                         |SET RECOVERY %2""",
	                         База,
	                         ВРег(МодельВосстановления));
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);
	
	Возврат КодВозврата = 0;
	
КонецФункции // УстановитьМодельВосстановления()

// Функция изменяет владельца базы
//
// Параметры:
//    База                 - Строка    - имя базы данных
//    НовыйВладелец        - Строка    - новый владелец базы
//    ОписаниеРезультата   - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево    - Истина - команда выполнена успешно
//
Функция УстановитьВладельцаБазы(База, НовыйВладелец, ОписаниеРезультата = "") Экспорт

	Если НЕ БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""ALTER AUTHORIZATION ON DATABASE::%1 TO %2""", База, НовыйВладелец);
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);
	
	Возврат КодВозврата = 0;
	
КонецФункции // УстановитьВладельцаБазы()

// Функция выполняет сжатие базы (shrink)
//
// Параметры:
//    База                 - Строка    - имя базы данных
//    ОписаниеРезультата   - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево    - Истина - команда выполнена успешно
//
Функция СжатьБазу(База, ОписаниеРезультата = "") Экспорт

	Если НЕ БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""DBCC SHRINKDATABASE(N'%1', 0)""", База);
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);
	
	Возврат КодВозврата = 0;
	
КонецФункции // СжатьБазу()

// Функция выполняет сжатие файла лог (shrink)
//
// Параметры:
//    База                - Строка - Имя базы данных
//    ОписаниеРезультата  - Строка - результат выполнения команды
//
// Возвращаемое значение:
//    Булево    - Истина - команда выполнена успешно
//
Функция СжатьФайлЛог(База, ОписаниеРезультата = "") Экспорт

	Если НЕ БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
		Возврат Ложь;
	КонецЕсли;
	
	ТекстЗапроса = СтрШаблон("""USE [%1];
	                         |
	                         |DBCC SHRINKFILE(N'%1_log', 0, TRUNCATEONLY); """,
	                         База);
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);
	
	Возврат КодВозврата = 0;
	
КонецФункции // СжатьФайлЛог()

// Функция выполняет выполняет компрессию базы и индексов на уровне страниц (DATA_COMPRESSION = PAGE)
//
// Параметры:
//    База                 - Строка    - имя базы данных
//    КомпрессияТаблиц     - Булево    - Истина - будет выполнена компрессия таблиц базы
//    КомпрессияИндексов   - Булево    - Истина - будет выполнена компрессия индексов базы
//    ОписаниеРезультата   - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево    - Истина - команда выполнена успешно
//
Функция ВключитьКомпрессиюСтраниц(База,
                                  КомпрессияТаблиц = Истина,
                                  КомпрессияИндексов = Истина,
                                  ОписаниеРезультата = "") Экспорт

	ОписаниеВерсии = ПолучитьВерсиюСУБД();

	Если НЕ ДоступностьФункционалаСУБД("Компрессия", ОписаниеВерсии) Тогда
		ОписаниеРезультата = СтрШаблон("Для данной версии СУБД ""MS SQL Server %1 %2""
		                               |не доступна функциональность компресии страниц!",
		                               ОписаниеВерсии.Версия,
		                               ОписаниеВерсии.Редакция);
		Возврат Истина;
	КонецЕсли;

	Если НЕ (КомпрессияТаблиц ИЛИ КомпрессияИндексов) Тогда
		ОписаниеРезультата = "Не указан флаг включения компрессии страниц для индексов или таблиц!";
		Возврат Истина;
	КонецЕсли;

	Если НЕ БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""USE [%1];", База);
	Если КомпрессияТаблиц Тогда
		ТекстЗапроса = СтрШаблон("%1%2EXEC sp_MSforeachtable 'ALTER TABLE ? REBUILD WITH (DATA_COMPRESSION = PAGE)'",
		                         ТекстЗапроса,
		                         Символы.ПС);
	КонецЕсли;

	Если КомпрессияИндексов Тогда
		ТекстЗапроса = СтрШаблон("%1%2EXEC sp_MSforeachtable 'ALTER INDEX ALL ON ? REBUILD WITH (DATA_COMPRESSION = PAGE)'",
		                         ТекстЗапроса,
		                         Символы.ПС);
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("%1""", ТекстЗапроса);
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);
	
	Возврат КодВозврата = 0;
	
КонецФункции // ВключитьКомпрессиюСтраниц()

// Функция создает файл резервной копии базы
//
// Параметры:
//    База                 - Строка    - имя базы данных
//    ПутьКРезервнойКопии  - Строка    - путь к файлу резервной копии
//    ОписаниеРезультата   - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево    - Истина - команда выполнена успешно
//
Функция СоздатьРезервнуюКопию(База, ПутьКРезервнойКопии, ОписаниеРезультата = "") Экспорт
	
	Если НЕ БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""BACKUP DATABASE [%1] TO DISK = N'%2'
	                         |WITH NOFORMAT, INIT, NAME = N'%1 FULL Backup',
	                         |SKIP,
	                         |NOREWIND,
	                         |NOUNLOAD,
	                         |COMPRESSION,
	                         |STATS = 10""",
	                         База,
	                         ПутьКРезервнойКопии);
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);

	Возврат КодВозврата = 0;
	
КонецФункции // СоздатьРезервнуюКопию()

// Функция выполняет восстановление базы из файла с резервной копией
//
// Параметры:
//    База                 - Строка    - имя базы данных
//    ПутьКРезервнойКопии  - Строка    - путь к файлу резервной копии
//    ПутьКФайлуДанных     - Строка    - путь к файлу базы
//    ПутьКФайлуЖурнала    - Строка    - путь к файлу журнала (transaction log) базы
//    СоздаватьБазу        - Булево    - Истина - будет создана новая база в случае отсутствия
//    ОписаниеРезультата   - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево    - Истина - команда выполнена успешно
//
Функция ВосстановитьИзРезервнойКопии(База,
                                     ПутьКРезервнойКопии,
                                     ПутьКФайлуДанных,
                                     ПутьКФайлуЖурнала,
                                     СоздаватьБазу = Ложь,
                                     ОписаниеРезультата = "") Экспорт
	
	Если НЕ БазаСуществует(База) Тогда
		Если НЕ СоздаватьБазу Тогда
			ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
			Возврат Ложь;
		Иначе
			Если НЕ СоздатьБазу(База, "SIMPLE", ОписаниеРезультата) Тогда
				Возврат Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	ЛогическоеИмяФайлаДанных = ПолучитьЛогическоеИмяФайлаВРезервнойКопии(ПутьКРезервнойКопии, "D");
	ЛогическоеИмяФайлаЖурнала = ПолучитьЛогическоеИмяФайлаВРезервнойКопии(ПутьКРезервнойКопии, "L");

	ТекстЗапроса = СтрШаблон("""USE [master];
	                         |
	                         |ALTER DATABASE [%1] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	                         |
	                         |RESTORE DATABASE [%1] FROM  DISK = N'%2' WITH  FILE = 1,
	                         |MOVE N'%3' TO N'%4\%1.mdf',
	                         |MOVE N'%5' TO N'%6\%1_log.ldf',
	                         |NOUNLOAD,  REPLACE,  STATS = 10;
	                         |
	                         |ALTER DATABASE [%1] SET MULTI_USER""",
	                         База,
	                         ПутьКРезервнойКопии,
	                         ЛогическоеИмяФайлаДанных,
	                         ПутьКФайлуДанных,
	                         ЛогическоеИмяФайлаЖурнала,
	                         ПутьКФайлуЖурнала);
	
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);

	Возврат КодВозврата = 0;

КонецФункции // ВосстановитьИзРезервнойКопии()

// Функция возвращает список полей таблицы информации о резервной копии
//
// Возвращаемое значение:
//    Строка    - список полей таблицы с информацией о резервной копии (разделенный ",")
//
Функция ПолучитьСписокПолейТаблицыФайловРезервнойКопии()

	ОписаниеПолей = "[LogicalName] nvarchar(128),
	                |[PhysicalName] nvarchar(260),
	                |[Type] char(1),
	                |[FileGroupName] nvarchar(128),
	                |[Size] numeric(20,0),
	                |[MaxSize] numeric(20,0),
	                |[FileID] bigint,
	                |[CreateLSN] numeric(25,0),
	                |[DropLSN] numeric(25,0) NULL,
	                |[UniqueID] uniqueidentifier,
	                |[ReadOnlyLSN] numeric(25,0) NULL,
	                |[ReadWriteLSN] numeric(25,0) NULL,
	                |[BackupSizeInBytes] bigint,
	                |[SourceBlockSize] int,
	                |[FileGroupID] int,
	                |[LogGroupGUID] uniqueidentifier NULL,
	                |[DifferentialBaseLSN] numeric(25,0) NULL,
	                |[DifferentialBaseGUID] uniqueidentifier,
	                |[IsReadOnly] bit,
	                |[IsPresent] bit,
	                |[TDEThumbprint] varbinary(32)";

	ОписаниеВерсии = ПолучитьВерсиюСУБД();
	
	Если ОписаниеВерсии.ВерсияМакс >= 13 Тогда
		ОписаниеПолей = СтрШаблон("%1,
		                          |[SnapshotUrl] nvarchar(360)",
		                          ОписаниеПолей);
	КонецЕсли;
	
	Возврат ОписаниеПолей;

КонецФункции // ПолучитьСписокПолейТаблицыФайловРезервнойКопии()

// Функция возвращает логическое имя файла в резервной копии
//
// Параметры:
//    ПутьКРезервнойКопии    - Строка    - путь к файлу резервной копии
//    ТипФайла               - Строка    - D - файл данных; L - файл журнала транзакций
//
// Возвращаемое значение:
//    Строка    - логическое имя файла базы в файле резервной копии
//
Функция ПолучитьЛогическоеИмяФайлаВРезервнойКопии(ПутьКРезервнойКопии, Знач ТипФайла = "D") Экспорт
	
	Если ВРег(ТипФайла) = "ROWS" Тогда
		ТипФайла = "D";
	ИначеЕсли ВРег(ТипФайла) = "LOG" Тогда
		ТипФайла = "L";
	КонецЕсли;

	Если НЕ (ВРег(ТипФайла) = "D" ИЛИ ВРег(ТипФайла) = "L") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТекстЗапроса = СтрШаблон("""SET NOCOUNT ON;
	                         |
	                         |DECLARE @T1CTmp TABLE (%1);
	                         |
	                         |INSERT INTO @T1CTmp EXECUTE('RESTORE FILELISTONLY FROM DISK = N''%2''');
	                         |
	                         |SELECT
	                         |	[LogicalName]
	                         |FROM
	                         |	@T1CTmp
	                         |WHERE
	                         |	[Type] = '%3';
	                         |
	                         |SET NOCOUNT OFF;""",
	                         ПолучитьСписокПолейТаблицыФайловРезервнойКопии(),
	                         ПутьКРезервнойКопии,
	                         ВРег(ТипФайла));
	
	РезультатЗапроса = "";
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса);

	Если КодВозврата = 0 Тогда
		Разделитель = "---";
		Поз = СтрНайти(РезультатЗапроса, Разделитель, НаправлениеПоиска.FromEnd);
		РезультатЗапроса = СокрЛП(Сред(РезультатЗапроса, Поз + СтрДлина(Разделитель)));
	КонецЕсли;

	Возврат РезультатЗапроса;

КонецФункции // ПолучитьЛогическоеИмяФайлаВРезервнойКопии()
	
// Функция возвращает логическое имя файла в базе
//
// Параметры:
//    База        - Строка    - имя базы данных
//    ТипФайла    - Строка    - ROWS - файл базы; LOG - файл журнала транзакций
//
// Возвращаемое значение:
//    Строка     - логическое имя файла базы
//
Функция ПолучитьЛогическоеИмяФайлаВБазе(База, Знач ТипФайла = "ROWS") Экспорт
	
	Если ВРег(ТипФайла) = "D" Тогда
		ТипФайла = "ROWS";
	ИначеЕсли ВРег(ТипФайла) = "L" Тогда
		ТипФайла = "LOG";
	КонецЕсли;

	Если НЕ (ВРег(ТипФайла) = "ROWS" ИЛИ ВРег(ТипФайла) = "LOG") Тогда
		Возврат Неопределено;
	КонецЕсли;

	Если НЕ БазаСуществует(База) Тогда
		Возврат Неопределено;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""SET NOCOUNT ON;
	                         |
	                         |SELECT
	                         |	[name]
	                         |FROM
	                         |	sys.master_files
	                         |WHERE
	                         |	[database_id]=db_id('%1')
	                         |		AND type_desc='%2';
	                         |
	                         |SET NOCOUNT OFF;""",
	                         База,
	                         ТипФайла);
	
	РезультатЗапроса = "";
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, РезультатЗапроса);

	РезультатЗапроса = Неопределено;

	Если КодВозврата = 0 Тогда
		Разделитель = "---";
		Поз = СтрНайти(РезультатЗапроса, Разделитель, НаправлениеПоиска.FromEnd);
		РезультатЗапроса = СокрЛП(Сред(РезультатЗапроса, Поз + СтрДлина(Разделитель)));
	КонецЕсли;

	Возврат РезультатЗапроса;

КонецФункции // ПолучитьЛогическоеИмяФайлаВБазе()

// Функция изменяет логическое имя файла базы
//
// Параметры:
//    База                 - Строка    - имя базы данных
//    Имя                  - Строка    - логическое имя изменяемого файла
//    НовоеИмя             - Строка    - новое логическое имя
//    ОписаниеРезультата   - Строка    - результат выполнения команды
//
// Возвращаемое значение:
//    Булево    - Истина - команда выполнена успешно
//
Функция ИзменитьЛогическоеИмяФайлаБазы(База, Имя, НовоеИмя, ОписаниеРезультата = "") Экспорт

	Если НЕ БазаСуществует(База) Тогда
		ОписаниеРезультата = СтрШаблон("База ""%1"" не существует!", База);
		Возврат Ложь;
	КонецЕсли;

	ТекстЗапроса = СтрШаблон("""USE [master];
	                         |
	                         |ALTER DATABASE [%1]
	                         |MODIFY FILE (NAME = N'%2', NEWNAME = N'%3');""",
	                         База,
	                         Имя,
	                         НовоеИмя);

	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата);

	Возврат КодВозврата = 0;

КонецФункции // ИзменитьЛогическоеИмяФайлаБазы()

// Функция возвращает описание установленной версии SQL Server
//
// Возвращаемое значение:
//	Структура            - описание версии SQL Server
//       ИмяСервера            - имя сервера
//       ИмяЭкземпляраСУБД     - имя экземпляра СУБД на сервере
//       Редакция              - номер редакции
//       Версия                - номер версии
//       Уровень               - уровень продукта
//       ВерсияМакс            - старший номер версии (2000 - 2000 (8)), 2005 - 9,
//                                                     2008 - 10, 2012 - 11, 2014 - 12, 2016 - 13)
//       Корп                  - признак Enterprise версии
//
Функция ПолучитьВерсиюСУБД() Экспорт
	
	ТекстЗапроса = """SET NOCOUNT ON;
	               |
	               |SELECT
	               |	SERVERPROPERTY('MachineName') AS ComputerName,
	               |	SERVERPROPERTY('ServerName') AS InstanceName,
	               |	SERVERPROPERTY('Edition') AS Edition,
	               |	SERVERPROPERTY('ProductVersion') AS ProductVersion,
	               |	SERVERPROPERTY('ProductLevel') AS ProductLevel""";

	ОписаниеРезультата = "";
	КодВозврата = ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата, "|", Истина);

	СтрокаОписанияВерсии = 3;
	ИмяСервера           = 0;
	ИмяЭкземпляраСУБД    = 1;
	Редакция             = 2;
	Версия               = 3;
	Уровень              = 4;
	
	// 2000 - 2000 (8)), 2005 - 9, 2008 - 10, 2012 - 11, 2014 - 12, 2016 - 13, 2017 - 14, 2019 - 15
	МассивВерсий = СтрРазделить("2000-8,9,10,11,12,13,14,15", ",");

	СоответствиеВерсий = Новый Соответствие();

	Для Каждого ТекВерсия Из МассивВерсий Цикл
		МассивВерсии = СтрРазделить(ТекВерсия, "-");

		Если МассивВерсии.Количество() = 1 Тогда
			СоответствиеВерсий.Вставить(МассивВерсии[0], Число(МассивВерсии[0]));
		ИначеЕсли МассивВерсии.Количество() > 1 Тогда
			СоответствиеВерсий.Вставить(МассивВерсии[0], Число(МассивВерсии[1]));
		КонецЕсли;	
	КонецЦикла;
	
	Если КодВозврата = 0 Тогда
		СтруктураРезультата = Новый Структура();

		Текст = Новый ТекстовыйДокумент();
		Текст.УстановитьТекст(ОписаниеРезультата);
		
		МассивЗначений = СтрРазделить(Текст.ПолучитьСтроку(СтрокаОписанияВерсии), "|");

		СтруктураРезультата.Вставить("ИмяСервера"       , МассивЗначений[ИмяСервера]);
		СтруктураРезультата.Вставить("ИмяЭкземпляраСУБД", МассивЗначений[ИмяЭкземпляраСУБД]);
		СтруктураРезультата.Вставить("Редакция"         , МассивЗначений[Редакция]);
		СтруктураРезультата.Вставить("Версия"           , МассивЗначений[Версия]);
		СтруктураРезультата.Вставить("Уровень"          , МассивЗначений[Уровень]);
		
		МассивВерсии = СтрРазделить(СтруктураРезультата["Версия"], ".");
		СтруктураРезультата.Вставить("ВерсияМакс"       , СоответствиеВерсий[МассивВерсии[0]]);

		СтруктураРезультата.Вставить("Корп"             , СтрНайти(ВРег(СтруктураРезультата["Редакция"]), "ENTERPRISE") > 0);

		Возврат СтруктураРезультата;
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции // ПолучитьВерсиюСУБД()

// Функция возвращает признак доступности функционала SQL Server
//
// Параметры:
//	Функционал        - Строка            - наименование проверяемого функционала
//	ОписаниеВерсии    - Соответствие      - наименование проверяемого функционала
//
// Возвращаемое значение:
//	Булево            - Истина - функционал доступен
//
Функция ДоступностьФункционалаСУБД(Знач Функционал, ОписаниеВерсии = Неопределено) Экспорт

	МинВерсияАвторизации = 10;
	МинВерсияКомпресии = 13;

	СтруктураФункционала = Новый Структура("Компрессия, ИзменениеАвторизации", Ложь, Ложь);

	Если НЕ ТипЗнч(ОписаниеВерсии) = Тип("Соответствие") Тогда
		ОписаниеВерсии = ПолучитьВерсиюСУБД();
	КонецЕсли;

	Если ОписаниеВерсии = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;

	Если ОписаниеВерсии.ВерсияМакс >= МинВерсияАвторизации Тогда
		СтруктураФункционала.ИзменениеАвторизации = Истина;
	КонецЕсли;

	Если ОписаниеВерсии.ВерсияМакс >= МинВерсияКомпресии ИЛИ ОписаниеВерсии.Корп Тогда
		СтруктураФункционала.Компрессия = Истина;
	КонецЕсли;

	Если НЕ СтруктураФункционала.Свойство(Функционал) Тогда
		Возврат Ложь;
	КонецЕсли;

	Возврат СтруктураФункционала[Функционал];

КонецФункции // ДоступностьФункционалаСУБД()

////////////////////////////////////////////////////////////////////////////////
// Служебные процедуры и функции

// Функция выполняет запрос к СУБД (используется консольная утилита sqlcmd)
//
// Параметры:
//    ТекстЗапроса           - Строка       - текст исполняемого запроса
//    ОписаниеРезультата     - Строка       - результат выполнения команду
//    Разделитель            - Строка       - символ - разделитель колонок результата
//    УбратьПробелы          - Булево       - Истина - будут убраны выравнивающие пробелы из результата
//
// Возвращаемое значение:
//	Булево       - Истина - команда выполнена успешно
//
Функция ВыполнитьЗапросСУБД(ТекстЗапроса, ОписаниеРезультата = "", Разделитель = "", УбратьПробелы = Ложь) Экспорт

	Лог.Отладка("Текст запроса: %1", ТекстЗапроса);
	
	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("sqlcmd");
	КомандаРК.ДобавитьПараметр("-S " + Сервер);
	Если ЗначениеЗаполнено(Пользователь) Тогда
		КомандаРК.ДобавитьПараметр("-U " + Пользователь);
		Если ЗначениеЗаполнено(пароль) Тогда
			КомандаРК.ДобавитьПараметр("-P " + Пароль);
		КонецЕсли;
	КонецЕсли;
	КомандаРК.ДобавитьПараметр("-Q " + ТекстЗапроса);
	КомандаРК.ДобавитьПараметр("-b");

	Если ЗначениеЗаполнено(Разделитель) Тогда
		КомандаРК.ДобавитьПараметр(СтрШаблон("-s ""%1""", Разделитель));
	КонецЕсли;

	Если УбратьПробелы Тогда
		КомандаРК.ДобавитьПараметр("-W");
	КонецЕсли;

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы( Ложь );
	КомандаРК.ПоказыватьВыводНемедленно( Ложь );
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();

	Возврат КодВозврата;

КонецФункции // ВыполнитьЗапросСУБД()

// Функция выполняет запрос к СУБД, выполняя текст из файлов скриптов (используется консольная утилита sqlcmd)
//
// Параметры:
//    МассивСкриптов       - Массив из Строка - массив с путями к файлам скриптов
//    МассивПеременных     - Массив из Строка - массив со значениями переменных вида "<Имя>=<Значение>"
//    ОписаниеРезультата   - Строка - результат выполнения команды
//
// Возвращаемое значение:
//    Булево       - Истина - команда выполнена успешно
//
Функция ВыполнитьСкриптыЗапросСУБД(МассивСкриптов, МассивПеременных = Неопределено, ОписаниеРезультата = "") Экспорт
	
	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("sqlcmd");
	КомандаРК.ДобавитьПараметр("-S " + Сервер);
	Если ЗначениеЗаполнено(Пользователь) Тогда
		КомандаРК.ДобавитьПараметр("-U " + Пользователь);
		Если ЗначениеЗаполнено(пароль) Тогда
			КомандаРК.ДобавитьПараметр("-P " + Пароль);
		КонецЕсли;
	КонецЕсли;

	Для каждого Файл Из МассивСкриптов Цикл
		Лог.Отладка("Добавлен файл скрипта: %1", Файл);

		КомандаРК.ДобавитьПараметр(СтрШаблон("-i %1", Файл));		
	КонецЦикла;
	
	Если ТипЗнч(МассивПеременных) = Тип("Массив") Тогда
		Для каждого Переменная Из МассивПеременных Цикл
			Лог.Отладка("Добавлено значение переменной: %1", Переменная);
			
			КомандаРК.ДобавитьПараметр(СтрШаблон("-v %1", Переменная));		
		КонецЦикла;
	КонецЕсли;

	КомандаРК.ДобавитьПараметр("-b");

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы( Ложь );
	КомандаРК.ПоказыватьВыводНемедленно( Ложь );
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();

	Возврат КодВозврата;

КонецФункции // ВыполнитьСкриптыЗапросСУБД()

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// Параметры:
//    _Сервер          - Строка    - адрес сервера СУБД
//    _Пользователь    - Строка    - пользователь сервера СУБД
//    _Пароль          - Строка    - пароль пользователя сервера СУБД
//
// Возвращаемое значение:
//    Булево    - Истина - команда выполнена успешно
//
Процедура ПриСозданииОбъекта(Знач _Сервер, Знач _Пользователь, Знач _Пароль) Экспорт
	
	Сервер       = _Сервер;
	Пользователь = _Пользователь;
	Пароль       = _Пароль;
	
	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПриСозданииОбъекта()

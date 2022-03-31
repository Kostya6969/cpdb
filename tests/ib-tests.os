﻿#Использовать fs
#Использовать "../src/core"

Перем ПрефиксИмениИБ;            //    - префикс имен тестовых баз
Перем ШаблонБазы;                //    - путь к файлу шаблона базы для тестов
Перем КаталогВременныхДанных;    //    - путь к каталогу временных данных
Перем Лог;                       //    - логгер

// Процедура выполняется после запуска теста
//
Процедура ПередЗапускомТеста() Экспорт
	
	КаталогВременныхДанных = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "build", "tmpdata");

	ПрефиксИмениИБ = "cpdb_test_db";

	ШаблонБазы = ОбъединитьПути(ТекущийСценарий().Каталог, "fixtures", "cpdb_test_db.dt");

	Лог = ПараметрыСистемы.Лог();
	Лог.УстановитьУровень(УровниЛога.Информация);

КонецПроцедуры // ПередЗапускомТеста()

// Процедура выполняется после запуска теста
//
Процедура ПослеЗапускаТеста() Экспорт

КонецПроцедуры // ПослеЗапускаТеста()

&Тест
Процедура ТестДолжен_СоздатьФайловуюБазу1С() Экспорт

	ИмяИБ = СтрШаблон("%1%2", ПрефиксИмениИБ, 1);

	КаталогИБ = ОбъединитьПути(КаталогВременныхДанных, ИмяИБ);

	ФС.ОбеспечитьПустойКаталог(КаталогИБ);

	РаботаСИБ.СоздатьФайловуюБазу(КаталогИБ, "8.3", , ШаблонБазы);

	ТекстОшибки = СтрШаблон("Ошибка создания базы 1С в каталоге ""%1"" из шаблона ""%2""", КаталогИБ, ШаблонБазы);

	ФайлБазы = Новый Файл(ОбъединитьПути(КаталогИБ, "1Cv8.1CD"));

	Утверждения.ПроверитьИстину(ФайлБазы.Существует(), ТекстОшибки);

	УдалитьФайлы(КаталогВременныхДанных);

КонецПроцедуры // ТестДолжен_СоздатьФайловуюБазу1С()

&Тест
Процедура ТестДолжен_ВыгрузитьБазуВФайл() Экспорт

	ИмяИБ = СтрШаблон("%1%2", ПрефиксИмениИБ, 1);

	КаталогИБ = ОбъединитьПути(КаталогВременныхДанных, ИмяИБ);
	ПутьКФайлуВыгрузки = ОбъединитьПути(КаталогВременныхДанных, СтрШаблон("%1-1Cv8.dt", ИмяИБ));

	ФС.ОбеспечитьПустойКаталог(КаталогИБ);

	РаботаСИБ.СоздатьФайловуюБазу(КаталогИБ, "8.3", , ШаблонБазы);

	ТекстОшибки = СтрШаблон("Ошибка создания базы 1С в каталоге ""%1"" из шаблона ""%2""", КаталогИБ, ШаблонБазы);

	ФайлБазы = Новый Файл(ОбъединитьПути(КаталогИБ, "1Cv8.1CD"));

	Утверждения.ПроверитьИстину(ФайлБазы.Существует(), ТекстОшибки);

	ПараметрыИБ = Новый Структура();
	ПараметрыИБ.Вставить("СтрокаПодключения", СтрШаблон("/F""%1""", КаталогИБ));
	ПараметрыИБ.Вставить("Пользователь", "");
	ПараметрыИБ.Вставить("Пароль", "");

	РаботаСИБ.ВыгрузитьИнформационнуюБазуВФайл(ПараметрыИБ, ПутьКФайлуВыгрузки, "8.3");
	
	ТекстОшибки = СтрШаблон("Ошибка выгрузки базы 1С ""%1"" в файл ""%2""", КаталогИБ, ПутьКФайлуВыгрузки);

	ФайлВыгрузки = Новый Файл(ПутьКФайлуВыгрузки);

	Утверждения.ПроверитьИстину(ФайлВыгрузки.Существует(), ТекстОшибки);

	УдалитьФайлы(КаталогВременныхДанных);

КонецПроцедуры // ТестДолжен_ВыгрузитьБазуВФайл()

&Тест
Процедура ТестДолжен_ЗагрузитьБазуИзФайла() Экспорт

	ИмяИБ = СтрШаблон("%1%2", ПрефиксИмениИБ, 1);

	КаталогИБ = ОбъединитьПути(КаталогВременныхДанных, ИмяИБ);

	ФС.ОбеспечитьПустойКаталог(КаталогИБ);

	РаботаСИБ.СоздатьФайловуюБазу(КаталогИБ, "8.3");

	ТекстОшибки = СтрШаблон("Ошибка создания базы 1С в каталоге ""%1""", КаталогИБ);

	ФайлБазы = Новый Файл(ОбъединитьПути(КаталогИБ, "1Cv8.1CD"));

	Утверждения.ПроверитьИстину(ФайлБазы.Существует(), ТекстОшибки);

	ПараметрыИБ = Новый Структура();
	ПараметрыИБ.Вставить("СтрокаПодключения", СтрШаблон("/F""%1""", КаталогИБ));
	ПараметрыИБ.Вставить("Пользователь", "");
	ПараметрыИБ.Вставить("Пароль", "");

	РаботаСИБ.ЗагрузитьИнформационнуюБазуИзФайла(ПараметрыИБ, ШаблонБазы, "8.3");
	
	// ТекстОшибки = СтрШаблон("Ошибка загрузки базы 1С ""%1"" из файла ""%2""", КаталогИБ, ШаблонБазы);

	УдалитьФайлы(КаталогВременныхДанных);

КонецПроцедуры // ТестДолжен_ЗагрузитьБазуИзФайла()

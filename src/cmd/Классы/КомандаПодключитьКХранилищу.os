// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

#Использовать "../../core"

Перем Лог;       // - Объект      - объект записи лога приложения

#Область СлужебныйПрограммныйИнтерфейс

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("pp params", "", "Файлы JSON содержащие значения параметров,
	                               | могут быть указаны несколько файлов разделенные "";""")
	       .ТСтрока()
	       .ВОкружении("CPDB_PARAMS");

	Команда.Опция("C ib-path ibconnection", "", "строка подключения к ИБ")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_IB_CONNECTION");
	
	Команда.Опция("U ib-user", "", "пользователь ИБ")
	       .ТСтрока()
	       .ВОкружении("CPDB_IB_USER");
	
	Команда.Опция("P ib-pwd", "", "пароль пользователя ИБ")
	       .ТСтрока()
	       .ВОкружении("CPDB_IB_PWD");
	
	Команда.Опция("e extension", "", "имя расширения, отключаемого от хранилища")
	       .ТСтрока()
	       .ВОкружении("CPDB_IB_EXTENSION");
	
	Команда.Опция("s storage-path", "", "адрес хранилища конфигурации")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_IB_STORAGE_PATH");
	
	Команда.Опция("u storage-user", "", "пользователь хранилища конфигурации")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_IB_STORAGE_USER");
	
	Команда.Опция("p storage-pwd", "", "пароль пользователя хранилища конфигурации")
	       .ТСтрока()
	       .ВОкружении("CPDB_IB_STORAGE_PWD");
	
	Команда.Опция("ui update-ib", Ложь, "обновить конфигурацию информационной базы")
	       .Флаговый()
	       .ВОкружении("CPDB_IB_UPDATE");
	
	Команда.Опция("uc uccode", "", "ключ разрешения запуска ИБ")
	       .ТСтрока()
	       .ВОкружении("CPDB_IB_UC_CODE");

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ЧтениеОпций = Новый ЧтениеОпцийКоманды(Команда);

	ВыводОтладочнойИнформации = ЧтениеОпций.ЗначениеОпции("verbose");

	ПараметрыСистемы.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	ПараметрыИБ        = Новый Структура();
	ПараметрыХранилища = Новый Структура();

	ПараметрыИБ.Вставить("СтрокаПодключения", ЧтениеОпций.ЗначениеОпции("ib-path"));
	ПараметрыИБ.Вставить("Пользователь",      ЧтениеОпций.ЗначениеОпции("ib-user"));
	ПараметрыИБ.Вставить("Пароль",            ЧтениеОпций.ЗначениеОпции("ib-pwd"));

	ПараметрыХранилища.Вставить("Адрес",        ЧтениеОпций.ЗначениеОпции("storage-path"));
	ПараметрыХранилища.Вставить("Пользователь", ЧтениеОпций.ЗначениеОпции("storage-user"));
	ПараметрыХранилища.Вставить("Пароль",       ЧтениеОпций.ЗначениеОпции("storage-pwd"));

	ИмяРасширения                = ЧтениеОпций.ЗначениеОпции("extension");
	ОбновитьИБ                   = ЧтениеОпций.ЗначениеОпции("update-ib");
	ИспользуемаяВерсияПлатформы  = ЧтениеОпций.ЗначениеОпции("v8version", Истина);
	КлючРазрешения               = ЧтениеОпций.ЗначениеОпции("uccode");

	РаботаСИБ.ПодключитьКХранилищу(ПараметрыИБ,
	                               ПараметрыХранилища,
	                               ИспользуемаяВерсияПлатформы,
	                               ИмяРасширения,
	                               ОбновитьИБ,
	                               КлючРазрешения);

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта()

	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий

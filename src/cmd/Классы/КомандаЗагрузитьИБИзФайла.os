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
	
	Команда.Опция("dp dt-path", "", "путь к DT-файлу для загрузки ИБ")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_IB_DT_PATH");
	
	Команда.Опция("uc uccode", "", "ключ разрешения запуска ИБ")
	       .ТСтрока()
	       .ВОкружении("CPDB_IB_UC_CODE");
	
	Команда.Опция("ds delsrc", Ложь, "удалить DT-файл после загрузки")
	       .Флаговый()
	       .ВОкружении("CPDB_IB_DT_DEL_SRC");

	Команда.Опция("vv v8version", "", "маска версии платформы 1С")
	       .ТСтрока()
	       .ВОкружении("CPDB_IB_V8VERSION");

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ВыводОтладочнойИнформации = Команда.ЗначениеОпции("verbose");

	ПараметрыСистемы.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	Если НЕ ПараметрыПриложения.ОбязательныеПараметрыЗаполнены(Команда) Тогда
		Команда.ВывестиСправку();
		Возврат;
	КонецЕсли;

	ПараметрыИБ        = Новый Структура();

	ПараметрыИБ.Вставить("СтрокаПодключения", Команда.ЗначениеОпции("ib-path"));
	ПараметрыИБ.Вставить("Пользователь",      Команда.ЗначениеОпции("ib-user"));
	ПараметрыИБ.Вставить("Пароль",            Команда.ЗначениеОпции("ib-pwd"));

	ПутьКФайлу                  = Команда.ЗначениеОпции("dt-path");
	КлючРазрешения              = Команда.ЗначениеОпции("uccode");
	УдалитьИсточник             = Команда.ЗначениеОпции("delsrc");
	ИспользуемаяВерсияПлатформы = Команда.ЗначениеОпции("v8version");
	
	РаботаСИБ.ЗагрузитьИнформационнуюБазуИзФайла(ПараметрыИБ,
	                                             ПутьКФайлу,
	                                             ИспользуемаяВерсияПлатформы,
	                                             КлючРазрешения);

	Если УдалитьИсточник Тогда
		УдалитьФайлы(ПутьКФайлу);
		Лог.Информация("Исходный файл %1 удален", ПутьКФайлу);
	КонецЕсли;

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

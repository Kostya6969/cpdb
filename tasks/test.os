#Использовать 1testrunner

Процедура ПровестиТестирование()
	
	Тестер = Новый Тестер;
	Тестер.ПодробныеОписанияОшибок(Истина);

	КаталогПроекта = ОбъединитьПути(ТекущийСценарий().Каталог, "..");
	КаталогРезультатовТестов = Новый Файл(ОбъединитьПути(КаталогПроекта, "build", "reports"));
	Если Не КаталогРезультатовТестов.Существует() Тогда
		СоздатьКаталог(КаталогРезультатовТестов.ПолноеИмя);
	КонецЕсли;

	ФайлРезультатовТестовПакета = Новый Файл(КаталогРезультатовТестов.ПолноеИмя);
	КаталогТестов = Новый Файл(ОбъединитьПути(КаталогПроекта, "tests"));

	Тестер.УстановитьФорматЛогФайла(Тестер.ФорматыЛогФайла().GenericExec);
	
	Тестер.ТестироватьКаталог(КаталогТестов, ФайлРезультатовТестовПакета);

КонецПроцедуры

ПровестиТестирование();

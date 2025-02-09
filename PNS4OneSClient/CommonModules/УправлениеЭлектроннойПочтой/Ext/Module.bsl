﻿#Область СлужебныеПроцедурыИФункции

&Вместо("ЗагрузитьЭлектронныеПисьма")
Функция pns4ones_ЗагрузитьЭлектронныеПисьма(ПолученныеПисьма)
	
	Результат = ПродолжитьВызов(ПолученныеПисьма);
	
	ОповеститьПользователейОНовыхПисьмах(ПолученныеПисьма.ПолученныеПисьмаПоУчетнойЗаписи);
	
	Возврат Результат;
	
КонецФункции

Процедура ОповеститьПользователейОНовыхПисьмах(ПолученныеПисьма)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ЭлектронноеПисьмо.Ссылка КАК Письмо,
	|	ПРЕДСТАВЛЕНИЕ(ЭлектронноеПисьмо.Ссылка) КАК ПисьмоПредставление,
	|	УчетныеЗаписи.ВладелецУчетнойЗаписи КАК Получатель
	|ИЗ
	|	Документ.ЭлектронноеПисьмоВходящее КАК ЭлектронноеПисьмо
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.УчетныеЗаписиЭлектроннойПочты КАК УчетныеЗаписи
	|		ПО ЭлектронноеПисьмо.УчетнаяЗапись = УчетныеЗаписи.Ссылка
	|ГДЕ
	|	ЭлектронноеПисьмо.Ссылка В(&ПолученныеПисьма)
	|ИТОГИ
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ Письмо)
	|ПО
	|	Получатель");
	Запрос.УстановитьПараметр("ПолученныеПисьма", ПолученныеПисьма);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	ВыборкаПолучатели = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаПолучатели.Следующий() Цикл
		
		Если ЗначениеЗаполнено(ВыборкаПолучатели.Получатель) Тогда
			ИдентификаторПользователя = pns4ones_СервисУведомлений.ПолучитьИдентификаторПользователя(ВыборкаПолучатели.Получатель);
			Получатель = pns4ones_СервисУведомленийКлиентСервер.ПолучательПользователь(ИдентификаторПользователя);
		Иначе
			Получатель = pns4ones_СервисУведомленийКлиентСервер.ПолучательВсеПользователи();
		КонецЕсли;
		
		КоличествоПисем = ВыборкаПолучатели.Письмо;
		
		Если КоличествоПисем = 1 Тогда
			
			Выборка = ВыборкаПолучатели.Выбрать();
			Выборка.Следующий();
			
			ТекстСообщения = НСтр("ru='Новое письмо'") + ": " + Выборка.ПисьмоПредставление;
			Действие = ПолучитьНавигационнуюСсылку(Выборка.Письмо);
			
		Иначе
			
			ТекстСообщения = НСтр("ru='Получено'") + ": " +
				СтроковыеФункцииКлиентСервер.СтрокаСЧисломДляЛюбогоЯзыка(
					";%1 письмо;;%1 письма;%1 писем;%1 письма",
					КоличествоПисем
				);
			Действие = ПолучитьНавигационнуюСсылку(Метаданные.Документы.ЭлектронноеПисьмоВходящее);
				
		КонецЕсли;
		
		Оповещение = pns4ones_СервисУведомленийКлиентСервер.ИнициализироватьОповещение();
		Оповещение.Текст = НСтр("ru='Электронная почта'");
		Оповещение.Пояснение = ТекстСообщения;
		Оповещение.Статус = СтатусОповещенияПользователя.Важное;
		Оповещение.ДействиеПриНажатии = Действие;
		
		Сообщение = pns4ones_СервисУведомленийКлиентСервер.ИнициализироватьСообщение();
		Сообщение.Оповещение = Оповещение;
		
		Результат = pns4ones_СервисУведомлений.ОтправитьУведомление(Получатель, Сообщение);
		
		Если Не Результат.Успешно Тогда
			pns4ones_СервисУведомленийВызовСервера.ЗаписатьОшибкуВЖурналРегистрации(Результат.ТекстОшибки);
		КонецЕсли;
		
	КонецЦикла;
		
КонецПроцедуры

#КонецОбласти

﻿Процедура РассчитатьНачисления(НаборЗаписейРегистра, ТребуемыйВидРасчета, СписокСотрудников) Экспорт  
	
	Регистратор = НаборЗаписейРегистра.Отбор.Регистратор.Значение;  

	// Рассчитать первичные записи
	Если ТребуемыйВидРасчета = ПланыВидовРасчета.ОсновныеНачисления.Оклад Тогда  
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
 		"ВЫБРАТЬ
		| НачисленияДанныеГрафика.ЗначениеПериодДействия КАК Норма,
		| НачисленияДанныеГрафика.ЗначениеФактическийПериодДействия КАК Факт,
		| НачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки
		|ИЗ
		| РегистрРасчета.Начисления.ДанныеГрафика(Регистратор = &Регистратор И 
		| ВидРасчета = &ВидРасчета И Сотрудник В (&СписокСотрудников)) 
		| КАК НачисленияДанныеГрафика";                   
	
	Запрос.УстановитьПараметр("Регистратор", Регистратор);
	Запрос.УстановитьПараметр("ВидРасчета", ТребуемыйВидРасчета);
	Запрос.УстановитьПараметр("СписокСотрудников", СписокСотрудников);   
	
	ВыборкаРезультата = Запрос.Выполнить().Выбрать(); 	
	
	Для Каждого ЗаписьРегистра Из НаборЗаписейРегистра Цикл
		СтруктураНомер = Новый Структура("НомерСтроки");
		СтруктураНомер.НомерСтроки = ЗаписьРегистра.НомерСтроки;
		ВыборкаРезультата.Сбросить(); 
		
		Если ВыборкаРезультата.НайтиСледующий(СтруктураНомер) Тогда     
			
			Если ВыборкаРезультата.Норма = 0 Тогда
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = "Вид расчета: Оклад – Нет рабочих дней в заданном периоде";
				Сообщение.Сообщить();
				ЗаписьРегистра.Результат = 0;
				
			Иначе                               
				
				// Рассчитать оклад по фактическому периоду и исходным данным
				ЗаписьРегистра.Результат = (ЗаписьРегистра.ИсходныеДанные / ВыборкаРезультата.Норма) * ВыборкаРезультата.Факт;
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = "Выполнен расчет " + ЗаписьРегистра.Регистратор + " – " + ЗаписьРегистра.ВидРасчета + " – " + 
				ЗаписьРегистра.Сотрудник;
				Сообщение.Сообщить();
				
			КонецЕсли;  
			
		КонецЕсли;        
		
	КонецЦикла;
		
	// Рассчитать вторичные записи
	ИначеЕсли ТребуемыйВидРасчета = ПланыВидовРасчета.ОсновныеНачисления.Премия Тогда  
	
		Запрос = Новый Запрос;
		Запрос.Текст = 
			 "ВЫБРАТЬ
			| НачисленияБазаНачисления.РезультатБаза КАК База,
			| НачисленияБазаНачисления.НомерСтроки КАК НомерСтроки
			|ИЗ
			| РегистрРасчета.Начисления.БазаНачисления(&ИзмеренияОсновного, 
			| &ИзмеренияБазового, , Регистратор = 
			| &Регистратор И ВидРасчета = &ВидРасчета И 
			| Сотрудник В (&СписокСотрудников))
			| КАК НачисленияБазаНачисления";  
		
		Измер = Новый Массив(1);
		Измер[0] = "Сотрудник";   
		
		Запрос.УстановитьПараметр("ИзмеренияОсновного", Измер);
		Запрос.УстановитьПараметр("ИзмеренияБазового", Измер);
		Запрос.УстановитьПараметр("Регистратор", Регистратор);
		Запрос.УстановитьПараметр("ВидРасчета", ТребуемыйВидРасчета);
		Запрос.УстановитьПараметр("СписокСотрудников", СписокСотрудников); 
		
		ВыборкаРезультата = Запрос.Выполнить().Выбрать(); 
		
		Для Каждого ЗаписьРегистра Из НаборЗаписейРегистра Цикл
			СтруктураНомер = Новый Структура("НомерСтроки");
			СтруктураНомер.НомерСтроки = ЗаписьРегистра.НомерСтроки;
			ВыборкаРезультата.Сбросить();     
			
			Если ВыборкаРезультата.НайтиСледующий(СтруктураНомер) Тогда
				ЗаписьРегистра.Результат = ВыборкаРезультата.База * (10 / 100);
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = "Выполнен расчет " + ЗаписьРегистра.Регистратор + " – " + ЗаписьРегистра.ВидРасчета + " – " + ЗаписьРегистра.Сотрудник;
				Сообщение.Сообщить();
				
			КонецЕсли; 
			
		КонецЦикла;

	КонецЕсли;    
	
КонецПроцедуры 

Процедура ПерерассчитатьНачисления(ТребуемыйВидРасчета) Экспорт
	// Здесь следует выбрать из набора записей перерасчета записи в следующей последовательности:
	// записи документа1 для сотрудников из списка,
	// записи документа2 для сотрудников из списка и т. д.
	Запрос = Новый Запрос(
		"ВЫБРАТЬ
		| НачисленияПерерасчет.ОбъектПерерасчета,
		| НачисленияПерерасчет.Сотрудник
		|ИЗ
		| РегистрРасчета.Начисления.Перерасчет КАК НачисленияПерерасчет
		|ГДЕ
		| НачисленияПерерасчет.ВидРасчета = &ТребуемыйВидРасчета
		|ИТОГИ ПО
		| НачисленияПерерасчет.ОбъектПерерасчета");        
	
		Запрос.УстановитьПараметр("ТребуемыйВидРасчета", ТребуемыйВидРасчета);
		СписокСотрудников = Новый СписокЗначений;
		
		// Перебрать группировку по регистратору.
		ВыборкаПоРегистратору = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаПоРегистратору.Следующий() Цикл
			Регистратор = ВыборкаПоРегистратору.ОбъектПерерасчета; 
			
			// Перебрать группировку по сотрудникам для выбранного регистратора 
			// и создать список сотрудников.
			ВыборкаПоСотрудникам = ВыборкаПоРегистратору.Выбрать();
			СписокСотрудников.Очистить();
			Пока ВыборкаПоСотрудникам.Следующий() Цикл
				СписокСотрудников.Добавить(ВыборкаПоСотрудникам.Сотрудник);
			КонецЦикла;     

			// Получить набор записей регистра расчета для выбранного регистратора.
			НаборЗаписей = РегистрыРасчета.Начисления.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Регистратор.Значение = Регистратор;
			НаборЗаписей.Прочитать();

			РассчитатьНачисления(НаборЗаписей, ТребуемыйВидРасчета, СписокСотрудников);
			НаборЗаписей.Записать( , Истина); 

			// Очистить перерассчитанные записи в перерасчете.
			НаборЗаписейПерерасчета = РегистрыРасчета.Начисления.Перерасчеты.Перерасчет.СоздатьНаборЗаписей();
			НаборЗаписейПерерасчета.Отбор.ОбъектПерерасчета.Значение = Регистратор;
			НаборЗаписейПерерасчета.Записать();  
		
		КонецЦикла;
	
КонецПроцедуры
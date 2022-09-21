//
//  MyWidget.swift
//  MyWidget
//
//  Created by 김종권 on 2022/09/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
  // 데이터를 불러오기 전(getSnapshot)에 보여줄 placeholder
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: ConfigurationIntent())
  }
  
  // 위젯 갤러리에서 위젯을 고를 때 보이는 샘플 데이터를 보여줄때 해당 메소드 호출
  // API를 통해서 데이터를 fetch하여 보여줄때 딜레이가 있는 경우 여기서 샘플 데이터를 하드코딩해서 보여주는 작업도 가능
  // context.isPreview가 true인 경우 위젯 갤러리에 위젯이 표출되는 상태
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), configuration: configuration)
    completion(entry)
  }
  
  // 홈화면에 있는 위젯을 언제 업데이트 시킬것인지 구현하는 부분
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    var entries: [SimpleEntry] = []
    
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      // 1시간뒤, 2시간뒤, ... 4시간뒤 entry 값으로 업데이트 하라는 코드
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate, configuration: configuration)
      entries.append(entry)
    }
    
    // (4시간뒤에 다시 타임라인을 새로 다시 불러옴)
    let timeline = Timeline(entries: entries, policy: .atEnd)
      // .atEnd: 마지막 date가 끝난 후 타임라인 reloading
      // .after: 다음 data가 지난 후 타임라인 reloading
      // .never: 즉시 타임라인 reloading
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
}

struct MyWidgetEntryView : View {
  var entry: Provider.Entry
  
  var body: some View {
    Text(entry.date, style: .time)
  }
}

@main
struct MyWidget: Widget {
  let kind: String = "MyWidget"
  
  // body 안에 사용하는 Configuration
    // IntentConfiguration: 사용자가 위젯에서 Edit을 통해 위젯에 보여지는 내용 변경이 가능
    // StaticConfiguration: 사용자가 변경 불가능한 정적 데이터 표출
  var body: some WidgetConfiguration {
    IntentConfiguration(
      kind: kind, // 위젯의 ID
      intent: ConfigurationIntent.self, // 사용자가 설정하는 컨피그
      provider: Provider() // 위젯 생성자 (타이밍 설정도 가능)
    ) { entry in
      // 위젯에 표출될 뷰
      MyWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
  }
}

struct MyWidget_Previews: PreviewProvider {
  static var previews: some View {
    MyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}

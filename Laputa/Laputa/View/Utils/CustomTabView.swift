//
//  CustomTabView.swift
//  Laputa
//
//  Created by Daniel Guillen on 3/12/21.
//

import SwiftUI

enum TabBarPosition {
    case top
    case bottom
}

struct CustomTabView<Content : View>: View {
    @State private var tabs: [CustomTab] = []
    @State var selectedTab: CustomTab?
    private let tabBarPosition: TabBarPosition
    private let numberOfTabs: Int
    private let content: Content
    
    init(
        tabBarPosition: TabBarPosition,
        numberOfElems: Int,
        @ViewBuilder content: () -> Content
    ) {
        self.tabBarPosition = tabBarPosition
        self.numberOfTabs = numberOfElems
        self.content = content()
    }
    
    public var tabBar: some View {
        HStack(alignment: .center) {
            ForEach(Array(tabs)) { tab in
                Button("\(tab.name)") {
                    self.selectedTab = tab
                }
                .font(.title3)
                .padding()
                .frame(height: self.numberOfTabs <= 1 ? 0 : 45)
                .foregroundColor(self.selectedTab == tab ? Color("HostMain") : Color.gray)
                .background(Color("TabBarBackground"))
            }
        }
        .frame(maxWidth: self.numberOfTabs <= 1 ? 0 : .infinity)
        .frame(height: self.numberOfTabs <= 1 ? 0 : 45)
        .background(Color("TabBarBackground"))
        .onChange(
            of: tabs,
            perform: { value in
                if self.tabs.count > 0 && self.selectedTab == nil {
                    self.selectedTab = self.tabs[0]
                }
            }
        )
        .onAppear(perform: {
            if self.tabs.count > 0 && self.selectedTab == nil {
                self.selectedTab = self.tabs[0]
            }
        })
    }
    
    var body: some View {
        return VStack(spacing: 0) {
                
            if (self.tabBarPosition == .top) {
                tabBar
            }
            
            VStack(spacing: 0) {
                ZStack {
                    content
                        .onPreferenceChange(CustomTabIdKey.self) { tabs in
                            self.tabs.insert(contentsOf: tabs, at: 0)
                        }
                        .environment(\.selectedCustomTabId, selectedTab)
                }
                .frame(maxHeight: .infinity)
            }

            
            if (self.tabBarPosition == .bottom) {
                tabBar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            if self.tabs.count > 0 && self.selectedTab == nil {
                self.selectedTab = self.tabs[0]
            }
        })
        .onChange(
            of: tabs,
            perform: { value in
                if self.tabs.count > 0 && self.selectedTab == nil {
                    self.selectedTab = self.tabs[0]
                }
            }
        )
    }
}

struct CustomTabIdKey: PreferenceKey {
    static var defaultValue: [CustomTab] = []
    
    static func reduce(value: inout [CustomTab], nextValue: () -> [CustomTab]) {
        value = nextValue()
    }
}

struct SelectedCustomTabIdKey: EnvironmentKey {
    static var defaultValue: CustomTab?
}

extension EnvironmentValues {
    var selectedCustomTabId: CustomTab? {
        get { self[SelectedCustomTabIdKey.self] }
        set { self[SelectedCustomTabIdKey.self] = newValue }
    }
}

// TabContainer wraps a passed in view in order to determine whether to
// show the given view at any moment.
struct TabContainer<Content: View>: View {
    let tab: CustomTab
    let content: Content
    
    // TabContainer retrieves the selectedCustomTabId environment
    // variable to know whether to display this tab's content or not.
    @Environment(\.selectedCustomTabId) var selectedId
    
    var body: some View {
        return ZStack {
            if tab == selectedId {
                content
            }
            else {
                EmptyView().frame(width: 0, height: 0)
            }
        }
    }
}

// CustomTab identifies a tab's content and corresponding view by ID and name.
struct CustomTab: Equatable, Hashable, Identifiable {
    let id: Int
    let name: String
}

// A view extension (that is required for the CustomTabView) that:
//  - sets each view's tab's text + creates unique ID for tab (customTab)
//  - wraps the view in a TabContainer for management by CustomTabView.
extension View {
    func customTab(name: String, tabNumber: Int) -> some View {
        let tab = CustomTab(id: tabNumber, name: name)
        return TabContainer(tab: tab, content: self)
            .preference(key: CustomTabIdKey.self, value: [tab])
    }
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView(
            tabBarPosition: TabBarPosition.top,
            numberOfElems: 2
        ) {
            ForEach(0..<2) {
                Text("Hello from: \($0)")
                    .customTab(name: "Session: \($0)", tabNumber: $0)
            }
        }
    }
}

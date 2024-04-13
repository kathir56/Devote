//
//  ContentView.swift
//  Devote
//
//  Created by Kathiravan Murali on 17/01/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var task : String = ""
    
    var isButtonDisabled : Bool {
        task.isEmpty
    }
    @FocusState private var dimissKeyboard : Bool
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        
        
        NavigationView {
            
            ZStack {
                
                
                VStack {
                    
                    VStack(spacing : 16) {
                        
                        TextField("Task",text: $task)
                            .focused($dimissKeyboard)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Button(action: {
                            task = ""
                            dimissKeyboard = false
                            addItem()
                        }, label: {
                            Spacer()
                            Text("SAVE")
                            Spacer()
                                
                            
                        })
                        .buttonStyle(.borderless)
                        .disabled(isButtonDisabled)
                        .padding()
                        .font(.headline)
                        .foregroundStyle(.white)
                        .background(Color(uiColor: isButtonDisabled ? .gray : .systemPink))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    }
                    .padding()
                    
                    List {
                        ForEach(items) { item in
                            NavigationLink {
                                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                            } label: {
                                VStack (alignment : .leading){
                                    Text(item.task ?? "")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Text(item.timestamp!, formatter: itemFormatter)
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        
                        .onDelete(perform: deleteItems)
                    }// Mark - list
                    
                    .listStyle(InsetGroupedListStyle())
                    
                    
                }// Vstack
                
             
            }// Mark - zstack
            .onAppear()
            {
                
            }
            .navigationTitle("Daliy Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    EditButton()
                    
                }
            }// Mark - toolbar
            .background(BackgroundImageView())
            .background(linearGradient.ignoresSafeArea(.all))
        }// navigation view
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.id = UUID()
            newItem.task = task
            newItem.completion = false

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

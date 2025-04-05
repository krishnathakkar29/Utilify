'use client';

import React, { useState } from "react";
import { Plus, X, Trash } from "lucide-react";

type Task = {
  text: string;
  completed: boolean;
};

type Tab = {
  name: string;
  tasks: Task[];
};

const Page = () => {
  const [tabs, setTabs] = useState<Tab[]>([{ name: "Today", tasks: [] }]);
  const [activeTab, setActiveTab] = useState(0);
  const [taskInput, setTaskInput] = useState("");
  const [tabNameInput, setTabNameInput] = useState("");

  const addTask = () => {
    if (!taskInput.trim()) return;
    const updatedTabs = [...tabs];
    updatedTabs[activeTab].tasks.push({ text: taskInput.trim(), completed: false });
    setTabs(updatedTabs);
    setTaskInput("");
  };

  const toggleTask = (taskIndex: number) => {
    const updatedTabs = [...tabs];
    updatedTabs[activeTab].tasks[taskIndex].completed =
      !updatedTabs[activeTab].tasks[taskIndex].completed;
    setTabs(updatedTabs);
  };

  const deleteTask = (taskIndex: number) => {
    const updatedTabs = [...tabs];
    updatedTabs[activeTab].tasks.splice(taskIndex, 1);
    setTabs(updatedTabs);
  };

  const addTab = () => {
    if (!tabNameInput.trim()) return;
    setTabs([...tabs, { name: tabNameInput.trim(), tasks: [] }]);
    setTabNameInput("");
  };

  const removeTab = (index: number) => {
    if (tabs.length === 1) return;
    const newTabs = tabs.filter((_, i) => i !== index);
    setTabs(newTabs);
    setActiveTab(index === activeTab ? 0 : activeTab - 1);
  };

  return (
    <div className="min-h-screen bg-zinc-900 text-white p-6">
        <h1 className="text-3xl text-bolder mb-2">TO DO</h1>
      <div className="flex items-center gap-4 overflow-x-auto">
        {tabs.map((tab, index) => (
          <div
            key={index}
            onClick={() => setActiveTab(index)}
            className={`relative px-4 py-2 rounded-t-lg cursor-pointer whitespace-nowrap transition-all duration-200 ${
              index === activeTab
                ? "bg-zinc-700 font-bold border-b-2 border-purple-500 text-purple-400"
                : "bg-zinc-800"
            }`}
          >
            {tab.name}
            <button
              className="ml-2 text-xs text-red-400 hover:text-red-600"
              onClick={(e) => {
                e.stopPropagation();
                removeTab(index);
              }}
            >
              <X size={14} />
            </button>
          </div>
        ))}
        <div className="flex items-center gap-2">
          <input
            className="bg-zinc-800 text-white p-1 rounded"
            value={tabNameInput}
            onChange={(e) => setTabNameInput(e.target.value)}
            placeholder="add tab"
          />
          <button
            className="text-purple-400 hover:text-purple-600"
            onClick={addTab}
          >
            <Plus />
          </button>
        </div>
      </div>

      <div className="bg-zinc-800 p-4 rounded-b-lg shadow-md mt-2">
        <ul className="space-y-2">
          {tabs[activeTab].tasks.map((task, idx) => (
            <li
              key={idx}
              className="flex items-center justify-between border-b border-zinc-600 py-2"
            >
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={task.completed}
                  onChange={() => toggleTask(idx)}
                  className="w-4 h-4 accent-purple-500"
                />
                <span className={task.completed ? "line-through text-zinc-400" : ""}>
                  {task.text}
                </span>
              </div>
              <button
                onClick={() => deleteTask(idx)}
                className="text-red-400 hover:text-red-600"
              >
                <Trash size={16} />
              </button>
            </li>
          ))}
        </ul>

        <div className="mt-4 flex gap-2">
          <input
            className="flex-1 p-2 rounded bg-zinc-700 text-white"
            placeholder="Add a new task"
            value={taskInput}
            onChange={(e) => setTaskInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && addTask()}
          />
          <button
            onClick={addTask}
            className="bg-purple-600 hover:bg-purple-700 px-4 py-2 rounded"
          >
            Add
          </button>
        </div>
      </div>
    </div>
  );
};

export default Page;

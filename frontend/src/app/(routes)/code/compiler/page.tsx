import CodeCompiler from '@/components/pages/code/compiler/code-compiler'

function page() {
  return (
    <div className="container max-w-[1400px] mx-auto">
        <div className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <h1 className="text-3xl font-bold tracking-tight">HTML/CSS/JS Compiler</h1>
            <p className="text-muted-foreground">
              Create and preview HTML, CSS, and JavaScript code in real-time
            </p>
          </div>
          <CodeCompiler />
        </div>
      </div>
  )
}

export default page
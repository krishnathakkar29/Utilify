"use client";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  type FollowUpSchemaType,
  followUpSchema,
} from "@/lib/schema/send-mail";
import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2, Paperclip, Send, X } from "lucide-react";
import { useCallback } from "react";
import { useDropzone } from "react-dropzone";
import { useForm } from "react-hook-form";
import { toast } from "sonner";
import { sendFollowUpEmail } from "../../../../actions/mail";

interface SendEmailDialogProps {
  isOpen: boolean;
  onClose: () => void;
  selectedEmails: Array<{
    recipient: string;
    emailId: string;
    companyName: string;
  }>;
}

export function SendEmailDialog({
  isOpen,
  onClose,
  selectedEmails,
}: SendEmailDialogProps) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting, isLoading },
    reset,
    setValue,
    watch,
  } = useForm<FollowUpSchemaType>({
    resolver: zodResolver(followUpSchema),
    defaultValues: {
      recipients: selectedEmails.map(({ recipient, emailId }) => ({
        email: recipient,
        companyId: emailId, // Changed from emailId to companyId
      })),
      subject: "",
      body: "",
      password: "",
      files: [],
    },
  });

  const files = watch("files") || [];

  const onDrop = useCallback(
    (acceptedFiles: File[]) => {
      setValue("files", acceptedFiles);
    },
    [setValue]
  );

  const { getRootProps, getInputProps } = useDropzone({
    onDrop,
    accept: {
      "application/pdf": [".pdf"],
      "image/*": [".png", ".jpg", ".jpeg"],
      "application/msword": [".doc", ".docx"],
    },
  });

  const removeFile = (index: number) => {
    const newFiles = [...files];
    newFiles.splice(index, 1);
    setValue("files", newFiles);
  };

  const onSubmit = async (data: FollowUpSchemaType) => {
    console.log("data", data);
    const loadingToast = toast.loading("Sending emails...");
    try {
      console.log("here", data);
      const result = await sendFollowUpEmail(data);
      console.log(result);
      if (result.success) {
        toast.dismiss(loadingToast);
        toast.success(result.message || "Email sent successfully");
        reset();
        onClose();
      } else {
        toast.dismiss(loadingToast);
        toast.error(result.error || "Failed to send email");
      }
    } catch (error: any) {
      toast.dismiss(loadingToast);
      toast.error(error?.message ?? "Failed to send email");
    }
  };

  const handleClose = () => {
    reset();
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Send Email to Selected Recipients</DialogTitle>
          <DialogDescription>
            You are sending an email to {selectedEmails.length}{" "}
            {selectedEmails.length === 1 ? "recipient" : "recipients"}.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4 py-4">
          <div className="space-y-2">
            <Label htmlFor="recipients">Recipients</Label>
            <div className="p-2 border rounded-md bg-muted/30 max-h-[100px] overflow-y-auto">
              {selectedEmails.map(
                ({ recipient, companyName, emailId }, index) => (
                  <div key={index} className="text-sm flex justify-between">
                    <span>{recipient}</span>
                    <span className="text-muted-foreground">{companyName}</span>
                    <input
                      type="hidden"
                      {...register(`recipients.${index}.email`)}
                      value={recipient}
                    />
                    <input
                      type="hidden"
                      {...register(`recipients.${index}.companyId`)} // Changed from emailId to companyId
                      value={emailId}
                    />
                  </div>
                )
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="subject">Subject</Label>
            <Input
              id="subject"
              placeholder="Enter email subject"
              {...register("subject")}
            />
            {errors.subject && (
              <p className="text-sm text-red-500">{errors.subject.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label>Attachments</Label>
            <div
              {...getRootProps()}
              className="border-2 border-dashed rounded-lg p-8 text-center cursor-pointer hover:bg-accent/50 transition-colors"
            >
              <input {...getInputProps()} />
              <div className="space-y-4">
                <Paperclip className="h-8 w-8 mx-auto text-muted-foreground" />
                <div>
                  <p className="font-medium">Drop files here</p>
                  <p className="text-sm text-muted-foreground mt-1">
                    or click to select files
                  </p>
                </div>
              </div>
            </div>

            {files.length > 0 && (
              <div className="space-y-2">
                <p className="text-sm font-medium">Selected Files</p>
                <div className="max-h-[200px] overflow-y-auto space-y-2">
                  {files.map((file, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between p-2 bg-accent/30 rounded"
                    >
                      <div className="flex items-center space-x-2 min-w-0">
                        <Paperclip className="h-4 w-4 shrink-0" />
                        <span className="text-sm truncate">{file.name}</span>
                      </div>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => removeFile(index)}
                        className="shrink-0"
                      >
                        <X className="h-4 w-4" />
                      </Button>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="body">Email Body</Label>
            <Textarea
              id="body"
              placeholder="Write your email content here..."
              className="min-h-[200px]"
              {...register("body")}
            />
            {errors.body && (
              <p className="text-sm text-red-500">{errors.body.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              placeholder="Enter your password"
              {...register("password")}
            />
            {errors.password && (
              <p className="text-sm text-red-500">{errors.password.message}</p>
            )}
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={handleClose}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={isLoading}>
              {isLoading ? (
                <>
                  <Loader2 className="h-5 w-5 mr-2 animate-spin" />
                  Sending...
                </>
              ) : (
                <>
                  <Send className="h-4 w-4 mr-2" />
                  Send Email
                </>
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
